// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// This file generates the extension methods public API and the extension
// methods patch file for all integers, double, and float.
// The PointerPointer and PointerStruct extension are written by hand since
// those are not repetitive.

import 'dart:io';

import 'package:args/args.dart';

//
// Configuration.
//

const configuration = [
  Config("Int8", "int", "Int8List", 1),
  Config("Int16", "int", "Int16List", 2),
  Config("Int32", "int", "Int32List", 4),
  Config("Int64", "int", "Int64List", 8),
  Config("Uint8", "int", "Uint8List", 1),
  Config("Uint16", "int", "Uint16List", 2),
  Config("Uint32", "int", "Uint32List", 4),
  Config("Uint64", "int", "Uint64List", 8),
  Config("Float", "double", "Float32List", 4),
  Config("Double", "double", "Float64List", 8),
  Config("Bool", "bool", kDoNotEmit, 1, since: Version(2, 15)),
];

/// A container to generate the extension for.
class Container {
  final String name;

  /// Since annotation for the extension.
  final Version? since;

  const Container(this.name, this.since);

  static const pointer = Container(
    'Pointer',
    null,
  );
  static const array = Container(
    'Array',
    Version(2, 13),
  );

  static const values = [
    pointer,
    array,
  ];
}

//
// Generator.
//

void main(List<String> arguments) {
  update(
    Uri.file('sdk/lib/ffi/ffi.dart'),
    generatePublicExtension,
  );
  update(
    Uri.file('sdk/lib/_internal/vm/lib/ffi_patch.dart'),
    generatePatchExtension,
  );
}

void update(Uri fileName, Function(StringBuffer, Config, Container) generator) {
  final file = File.fromUri(fileName);
  if (!file.existsSync()) {
    print('$fileName does not exist, run from the root of the SDK.');
    return;
  }

  final fileContents = file.readAsStringSync();
  final split1 = fileContents.split(header);
  if (split1.length != 2) {
    print('$fileName has unexpected contents.');
    print(split1.length);
    return;
  }
  final split2 = split1[1].split(footer);
  if (split2.length != 2) {
    print('$fileName has unexpected contents 2.');
    print(split2.length);
    return;
  }

  final buffer = StringBuffer();
  buffer.write(split1[0]);
  buffer.write(header);
  for (final container in Container.values) {
    for (final config in configuration) {
      generator(buffer, config, container);
    }
  }
  buffer.write(footer);
  buffer.write(split2[1]);

  file.writeAsStringSync(buffer.toString());
  final fmtResult =
      Process.runSync(dartPath(), ["format", fileName.toFilePath()]);
  if (fmtResult.exitCode != 0) {
    throw Exception(
        "Formatting failed:\n${fmtResult.stdout}\n${fmtResult.stderr}\n");
  }
  print("Updated $fileName.");
}

const header = """
//
// The following code is generated, do not edit by hand.
//
// Code generated by `runtime/tools/ffi/sdk_lib_ffi_generator.dart`.
//

""";

void generateHeader(StringBuffer buffer) {
  buffer.write(header);
}

void generatePublicExtension(
  StringBuffer buffer,
  Config config,
  Container container,
) {
  final nativeType = config.nativeType;
  final dartType = config.dartType;
  final typedListType = config.typedListType;
  final elementSize = config.elementSize;

  final bits = sizeOfBits(elementSize);

  String property;
  if (_isInt(nativeType)) {
    if (_isSigned(nativeType)) {
      property = "$bits-bit two's complement integer";
    } else {
      property = "$bits-bit unsigned integer";
    }
  } else if (nativeType == "Float") {
    property = "float";
  } else if (nativeType == "Double") {
    property = "double";
  } else if (nativeType == "Bool") {
    property = "bool";
  } else {
    throw "Unexpected type: $nativeType";
  }

  const platformIntPtr = """
  ///
  /// On 32-bit platforms this is a 32-bit integer, and on 64-bit platforms
  /// this is a 64-bit integer.
""";

  final platform = nativeType == "IntPtr" ? platformIntPtr : "";

  final intSignedTruncate = """
  ///
  /// A Dart integer is truncated to $bits bits (as if by `.toSigned($bits)`) before
  /// being stored, and the $bits-bit value is sign-extended when it is loaded.
""";

  const intPtrTruncate = """
  ///
  /// On 32-bit platforms a Dart integer is truncated to 32 bits (as if by
  /// `.toSigned(32)`) before being stored, and the 32-bit value is
  /// sign-extended when it is loaded.
""";

  final intUnsignedTruncate = """
  ///
  /// A Dart integer is truncated to $bits bits (as if by `.toUnsigned($bits)`) before
  /// being stored, and the $bits-bit value is zero-extended when it is loaded.
""";

  const floatTruncate = """
  ///
  /// A Dart double loses precision before being stored, and the float value is
  /// converted to a double when it is loaded.
""";

  String truncate = "";
  if (nativeType == "IntPtr") {
    truncate = intPtrTruncate;
  } else if (_isInt(nativeType) && elementSize != 8) {
    truncate = _isSigned(nativeType) ? intSignedTruncate : intUnsignedTruncate;
  } else if (nativeType == "Float") {
    truncate = floatTruncate;
  }

  final alignmentDefault = """
  ///
  /// The [address] must be ${sizeOf(elementSize)}-byte aligned.
""";

  const alignmentIntptr = """
  ///
  /// On 32-bit platforms the [address] must be 4-byte aligned, and on 64-bit
  /// platforms the [address] must be 8-byte aligned.
""";

  String alignment = "";
  if (nativeType == "IntPtr") {
    alignment = alignmentIntptr;
  } else if (elementSize != 1) {
    alignment = alignmentDefault;
  }

  final asTypedList = typedListType == kDoNotEmit
      ? ""
      : """
  /// Creates a typed list view backed by memory in the address space.
  ///
  /// The returned view will allow access to the memory range from [address]
  /// to `address + sizeOf<$nativeType>() * length`.
  ///
  /// The user has to ensure the memory range is accessible while using the
  /// returned list.
  ///
  /// If provided, [finalizer] will be run on the pointer once the typed list
  /// is GCed. If provided, [token] will be passed to [finalizer], otherwise
  /// the this pointer itself will be passed.
$alignment  external $typedListType asTypedList(
    int length, {
    @Since('3.1') Pointer<NativeFinalizerFunction>? finalizer,
    @Since('3.1') Pointer<Void>? token,
  });
""";
  final since =
      Version.latest(config.since, container.since)?.sinceAnnotation ?? '';
  switch (container) {
    case Container.pointer:
      buffer.write("""
/// Extension on [Pointer] specialized for the type argument [$nativeType].
$since extension ${nativeType}Pointer on Pointer<$nativeType> {
  /// The $property at [address].
$platform$truncate$alignment  external $dartType get value;

  external void set value($dartType value);

  /// The $property at `address + sizeOf<$nativeType>() * index`.
$platform$truncate$alignment  external $dartType operator [](int index);

  /// The $property at `address + sizeOf<$nativeType>() * index`.
$platform$truncate$alignment  external void operator []=(int index, $dartType value);

  /// Pointer arithmetic (takes element size into account).
  @Deprecated('Use operator + instead')
  Pointer<$nativeType> elementAt(int index) => Pointer.fromAddress(address + sizeOf<$nativeType>() * index);

  /// A pointer to the [offset]th [$nativeType] after this one.
  ///
  /// Returns a pointer to the [$nativeType] whose address is
  /// [offset] times the size of `$nativeType` after the address of this pointer.
  /// That is `(this + offset).address == this.address + offset * sizeOf<$nativeType>()`.
  ///
  /// Also `(this + offset).value` is equivalent to `this[offset]`,
  /// and similarly for setting.
  @Since('3.3')
  @pragma("vm:prefer-inline")
  Pointer<$nativeType> operator +(int offset) => Pointer.fromAddress(address + sizeOf<$nativeType>() * offset);

  /// A pointer to the [offset]th [$nativeType] before this one.
  ///
  /// Equivalent to `this + (-offset)`.
  ///
  /// Returns a pointer to the [$nativeType] whose address is
  /// [offset] times the size of `$nativeType` before the address of this pointer.
  /// That is, `(this - offset).address == this.address - offset * sizeOf<$nativeType>()`.
  ///
  /// Also, `(this - offset).value` is equivalent to `this[-offset]`,
  /// and similarly for setting,
  @Since('3.3')
  @pragma("vm:prefer-inline")
  Pointer<$nativeType> operator -(int offset) => Pointer.fromAddress(address - sizeOf<$nativeType>() * offset);

$asTypedList
}

""");
    case Container.array:
      buffer.write("""
/// Bounds checking indexing methods on [Array]s of [$nativeType].
$since extension ${nativeType}Array on Array<$nativeType> {
  external $dartType operator [](int index);

  external void operator []=(int index, $dartType value);
}

""");
  }
}

void generatePatchExtension(
  StringBuffer buffer,
  Config config,
  Container container,
) {
  final nativeType = config.nativeType;
  final dartType = config.dartType;
  final typedListType = config.typedListType;
  final elementSize = config.elementSize;

  final sizeTimes =
      elementSize != 1 ? '${sizeOfIntPtrSize(elementSize)} * ' : '';

  final asTypedList = typedListType == kDoNotEmit
      ? ""
      : """
  @patch
  @pragma("vm:prefer-inline")
  $typedListType asTypedList(
    int length, {
     Pointer<NativeFinalizerFunction>? finalizer,
     Pointer<Void>? token,
  }) {
    ArgumentError.checkNotNull(this, "Pointer<$nativeType>");
    ArgumentError.checkNotNull(length, "length");
    _checkExternalTypedDataLength(length, $elementSize);
    _checkPointerAlignment(address, $elementSize);
    final result = _asExternalTypedData$nativeType(this, length);
    if (finalizer != null) {
      _attachAsTypedListFinalizer(finalizer, result, token ?? this, $sizeTimes length);
    }
    return result;
  }
""";

  switch (container) {
    case Container.pointer:
      buffer.write("""
@patch
extension ${nativeType}Pointer on Pointer<$nativeType> {
  @patch
  @pragma("vm:prefer-inline")
  $dartType get value => _load$nativeType(this, 0);

  @patch
  @pragma("vm:prefer-inline")
  set value($dartType value) => _store$nativeType(this, 0, value);

  @patch
  @pragma("vm:prefer-inline")
  $dartType operator [](int index) => _load$nativeType(this, ${sizeTimes}index);

  @patch
  @pragma("vm:prefer-inline")
  operator []=(int index, $dartType value) => _store$nativeType(this, ${sizeTimes}index, value);

$asTypedList
}

""");
    case Container.array:
      buffer.write("""
@patch
extension ${nativeType}Array on Array<$nativeType> {
  @patch
  $dartType operator [](int index) {
    _checkIndex(index);
    return _load$nativeType(_typedDataBase, ${sizeTimes}index);
  }

  @patch
  operator []=(int index, $dartType value) {
    _checkIndex(index);
    return _store$nativeType(_typedDataBase, ${sizeTimes}index, value);
  }
}

""");
  }
}

final footer = """
//
// End of generated code.
//
""";

void generateFooter(StringBuffer buffer) {
  buffer.write(footer);
}

//
// Helper functions.
//

bool _isInt(String type) => type.startsWith("Int") || type.startsWith("Uint");
bool _isSigned(String type) => type.startsWith("Int");

String sizeOf(int size) => "$size";

String sizeOfBits(int size) => "${size * 8}";

String sizeOfIntPtrSize(int size) => "$size";

String bracketOr(String input) {
  if (input.contains("or")) {
    return "($input)";
  }
  return input;
}

final Uri _containingFolder = File.fromUri(Platform.script).parent.uri;

ArgParser argParser() {
  final parser = ArgParser(allowTrailingOptions: false);
  parser.addOption('path',
      abbr: 'p',
      help: 'Path to generate the files at.',
      defaultsTo: _containingFolder.toString());
  parser.addFlag('help', abbr: 'h', help: 'Display usage information.',
      callback: (help) {
    if (help) print(parser.usage);
  });
  return parser;
}

String dartPath() {
  return File.fromUri(
          Platform.script.resolve("../../../tools/sdks/dart-sdk/bin/dart"))
      .path;
}

class Config {
  final String nativeType;
  final String dartType;
  final String typedListType;
  final int elementSize;
  final Version? since;
  const Config(
    this.nativeType,
    this.dartType,
    this.typedListType,
    this.elementSize, {
    Version? since,
  }) : since = since;
}

const String kDoNotEmit = "donotemit";

class Version {
  final int major;
  final int minor;

  const Version(this.major, this.minor);

  @override
  String toString() => '$major.$minor';

  static Version? latest(Version? a, Version? b) {
    if (a == null) return b;
    if (b == null) return a;
    if (a.major > b.major) return a;
    if (b.major > a.major) return b;
    if (a.minor > b.minor) return a;
    return b;
  }

  String get sinceAnnotation => "@Since('$this')";
}
