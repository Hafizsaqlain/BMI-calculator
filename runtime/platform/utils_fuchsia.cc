// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "platform/globals.h"
#if defined(DART_HOST_OS_FUCHSIA)

#include <memory>
#include <utility>

#include "lib/async/default.h"
#include "lib/inspect/component/cpp/component.h"
#include "lib/sys/cpp/component_context.h"
#include "platform/utils.h"
#include "platform/utils_fuchsia.h"

namespace dart {

char* Utils::StrNDup(const char* s, intptr_t n) {
  return strndup(s, n);
}

char* Utils::StrDup(const char* s) {
  return strdup(s);
}

intptr_t Utils::StrNLen(const char* s, intptr_t n) {
  return strnlen(s, n);
}

int Utils::SNPrint(char* str, size_t size, const char* format, ...) {
  va_list args;
  va_start(args, format);
  int retval = VSNPrint(str, size, format, args);
  va_end(args);
  return retval;
}

int Utils::VSNPrint(char* str, size_t size, const char* format, va_list args) {
  int retval = vsnprintf(str, size, format, args);
  if (retval < 0) {
    FATAL("Fatal error in Utils::VSNPrint with format '%s'", format);
  }
  return retval;
}

int Utils::Close(int fildes) {
  return close(fildes);
}
size_t Utils::Read(int filedes, void* buf, size_t nbyte) {
  return read(filedes, buf, nbyte);
}
int Utils::Unlink(const char* path) {
  return unlink(path);
}

sys::ComponentContext* ComponentContext() {
  static std::unique_ptr<sys::ComponentContext> context =
      sys::ComponentContext::CreateAndServeOutgoingDirectory();
  return context.get();
}

std::unique_ptr<inspect::Node> vm_node;
void SetDartVmNode(std::unique_ptr<inspect::Node> node) {
  vm_node = std::move(node);
}

std::unique_ptr<inspect::Node> TakeDartVmNode() {
  // TODO(fxbug.dev/69558) Remove the creation of the node_ from this call
  // after the runners have been migrated to injecting this object.
  if (vm_node == nullptr) {
    static std::unique_ptr<inspect::ComponentInspector> component_inspector =
        std::make_unique<inspect::ComponentInspector>(
            async_get_default_dispatcher(), inspect::PublishOptions{});
    vm_node = std::make_unique<inspect::Node>(
        component_inspector->root().CreateChild("vm"));
  }
  return std::move(vm_node);
}

}  // namespace dart

#endif  // defined(DART_HOST_OS_FUCHSIA)
