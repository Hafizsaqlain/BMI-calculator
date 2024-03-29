// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/resolver.h"

#include "vm/dart_entry.h"
#include "vm/flags.h"
#include "vm/isolate.h"
#include "vm/log.h"
#include "vm/object.h"
#include "vm/object_store.h"
#include "vm/symbols.h"

namespace dart {

DEFINE_FLAG(bool, trace_resolving, false, "Trace resolving.");

// The actual names of named arguments are not checked by the dynamic resolver,
// but by the method entry code. It is important that the dynamic resolver
// checks that no named arguments are passed to a method that does not accept
// them, since the entry code of such a method does not check for named
// arguments. The dynamic resolver actually checks that a valid number of named
// arguments is passed in.
FunctionPtr Resolver::ResolveDynamic(const Instance& receiver,
                                     const String& function_name,
                                     const ArgumentsDescriptor& args_desc) {
  // Figure out type of receiver first.
  const Class& cls = Class::Handle(receiver.clazz());
  return ResolveDynamicForReceiverClass(cls, function_name, args_desc);
}

static FunctionPtr ResolveDynamicAnyArgsWithCustomLookup(
    Zone* zone,
    const Class& receiver_class,
    const String& function_name,
    bool allow_add,
    std::function<FunctionPtr(Class&, const String&)> lookup) {
  Class& cls = Class::Handle(zone, receiver_class.ptr());
  if (FLAG_trace_resolving) {
    THR_Print("ResolveDynamic '%s' for class %s\n", function_name.ToCString(),
              String::Handle(zone, cls.Name()).ToCString());
  }
  Function& function = Function::Handle(zone);

  const String& demangled = String::Handle(
      zone,
      Function::IsDynamicInvocationForwarderName(function_name)
          ? Function::DemangleDynamicInvocationForwarderName(function_name)
          : function_name.ptr());

  const bool is_getter = Field::IsGetterName(demangled);
  String& demangled_getter_name = String::Handle();
  if (is_getter) {
    demangled_getter_name = Field::NameFromGetter(demangled);
  }

  const bool is_dyn_call = demangled.ptr() != function_name.ptr();

  Thread* thread = Thread::Current();
  bool need_to_create_method_extractor = false;
  while (!cls.IsNull()) {
    if (is_dyn_call) {
      // Try to find a dyn:* forwarder & return it.
      function = cls.GetInvocationDispatcher(
          function_name, Array::null_array(),
          UntaggedFunction::kDynamicInvocationForwarder,
          /*create_if_absent=*/false);
    }
    if (!function.IsNull()) return function.ptr();

    ASSERT(cls.is_finalized());
    {
      SafepointReadRwLocker ml(thread, thread->isolate_group()->program_lock());
      function = lookup(cls, demangled);
    }
#if !defined(DART_PRECOMPILED_RUNTIME)
    // In JIT we might need to lazily create a dyn:* forwarder.
    if (is_dyn_call && !function.IsNull()) {
      function =
          function.GetDynamicInvocationForwarder(function_name, allow_add);
    }
#endif
    if (!function.IsNull()) return function.ptr();

    // Getter invocation might actually be a method extraction.
    if (is_getter) {
      SafepointReadRwLocker ml(thread, thread->isolate_group()->program_lock());
      function = lookup(cls, demangled_getter_name);
      if (!function.IsNull()) {
        if (allow_add && FLAG_lazy_dispatchers) {
          need_to_create_method_extractor = true;
          break;
        } else {
          return Function::null();
        }
      }
    }
    cls = cls.SuperClass();
  }
  if (need_to_create_method_extractor) {
    // We were looking for the getter but found a method with the same
    // name. Create a method extractor and return it.
    // Use GetMethodExtractor instead of CreateMethodExtractor to ensure
    // nobody created method extractor since we last checked under ReadRwLocker.
    function = function.GetMethodExtractor(demangled);
  } else if (is_getter && receiver_class.IsRecordClass() && allow_add &&
             FLAG_lazy_dispatchers) {
    function = receiver_class.GetRecordFieldGetter(demangled);
  }
  return function.ptr();
}

static FunctionPtr ResolveDynamicForReceiverClassWithCustomLookup(
    const Class& receiver_class,
    const String& function_name,
    const ArgumentsDescriptor& args_desc,
    bool allow_add,
    std::function<FunctionPtr(Class&, const String&)> lookup) {
  Thread* thread = Thread::Current();
  Zone* zone = thread->zone();

  Function& function = Function::Handle(
      zone, ResolveDynamicAnyArgsWithCustomLookup(
                zone, receiver_class, function_name, allow_add, lookup));

#if defined(DART_PRECOMPILED_RUNTIME)
  if (!function.IsNull() && function.signature() == FunctionType::null()) {
    // FfiTrampolines are the only functions that can still be called
    // dynamically without going through a dynamic invocation forwarder.
    RELEASE_ASSERT(!Function::IsDynamicInvocationForwarderName(function_name) &&
                   !function.IsFfiCallbackTrampoline());
    // The signature for this function was dropped in the precompiler, which
    // means it is not a possible target for a dynamic call in the program.
    // That means we're resolving an UnlinkedCall for an InstanceCall to
    // a known interface. Since there's no overloading in Dart, the type checker
    // has already checked the validity of the arguments at compile time.
    return function.ptr();
  }
#endif

  if (function.IsNull() || !function.AreValidArguments(args_desc, nullptr)) {
    // Return a null function to signal to the upper levels to dispatch to
    // "noSuchMethod" function.
    if (FLAG_trace_resolving) {
      String& error_message =
          String::Handle(zone, Symbols::New(thread, "function not found"));
      if (!function.IsNull()) {
        // Obtain more detailed error message.
        function.AreValidArguments(args_desc, &error_message);
      }
      THR_Print("ResolveDynamic error '%s': %s.\n", function_name.ToCString(),
                error_message.ToCString());
    }
    return Function::null();
  }
  return function.ptr();
}

FunctionPtr Resolver::ResolveDynamicForReceiverClass(
    const Class& receiver_class,
    const String& function_name,
    const ArgumentsDescriptor& args_desc,
    bool allow_add) {
  return ResolveDynamicForReceiverClassWithCustomLookup(
      receiver_class, function_name, args_desc, allow_add,
      std::mem_fn(&Class::LookupDynamicFunctionUnsafe));
}

FunctionPtr Resolver::ResolveDynamicForReceiverClassAllowPrivate(
    const Class& receiver_class,
    const String& function_name,
    const ArgumentsDescriptor& args_desc,
    bool allow_add) {
  return ResolveDynamicForReceiverClassWithCustomLookup(
      receiver_class, function_name, args_desc, allow_add,
      std::mem_fn(&Class::LookupDynamicFunctionAllowPrivate));
}

FunctionPtr Resolver::ResolveFunction(Zone* zone,
                                      const Class& receiver_class,
                                      const String& function_name) {
  return ResolveDynamicAnyArgsWithCustomLookup(
      zone, receiver_class, function_name, /*allow_add=*/false,
      std::mem_fn(static_cast<FunctionPtr (Class::*)(const String&) const>(
          &Class::LookupFunctionReadLocked)));
}

FunctionPtr Resolver::ResolveDynamicFunction(Zone* zone,
                                             const Class& receiver_class,
                                             const String& function_name) {
  return ResolveDynamicAnyArgsWithCustomLookup(
      zone, receiver_class, function_name, /*allow_add=*/false,
      std::mem_fn(static_cast<FunctionPtr (Class::*)(const String&) const>(
          &Class::LookupDynamicFunctionUnsafe)));
}

FunctionPtr Resolver::ResolveDynamicAnyArgs(Zone* zone,
                                            const Class& receiver_class,
                                            const String& function_name,
                                            bool allow_add) {
  return ResolveDynamicAnyArgsWithCustomLookup(
      zone, receiver_class, function_name, allow_add,
      std::mem_fn(&Class::LookupDynamicFunctionUnsafe));
}

FunctionPtr Resolver::ResolveDynamicAnyArgsAllowPrivate(
    Zone* zone,
    const Class& receiver_class,
    const String& function_name,
    bool allow_add) {
  return ResolveDynamicAnyArgsWithCustomLookup(
      zone, receiver_class, function_name, allow_add,
      std::mem_fn(&Class::LookupDynamicFunctionAllowPrivate));
}

}  // namespace dart
