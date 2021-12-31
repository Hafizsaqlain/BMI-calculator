// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Directory, Platform;
import 'package:_fe_analyzer_shared/src/macros/api.dart';
import 'package:_fe_analyzer_shared/src/macros/executor.dart';
import 'package:_fe_analyzer_shared/src/testing/id.dart' show ActualData, Id;
import 'package:_fe_analyzer_shared/src/testing/id_testing.dart';
import 'package:_fe_analyzer_shared/src/testing/features.dart';
import 'package:front_end/src/api_prototype/compiler_options.dart';
import 'package:front_end/src/api_prototype/experimental_flags.dart';
import 'package:front_end/src/fasta/builder/class_builder.dart';
import 'package:front_end/src/fasta/builder/library_builder.dart';
import 'package:front_end/src/fasta/builder/member_builder.dart';
import 'package:front_end/src/fasta/kernel/macro.dart';
import 'package:front_end/src/testing/id_testing_helper.dart';
import 'package:kernel/ast.dart' hide Arguments;

Future<void> main(List<String> args) async {
  enableMacros = true;

  Directory dataDir =
      new Directory.fromUri(Platform.script.resolve('data/tests'));
  await runTests<Features>(dataDir,
      args: args,
      createUriForFileName: createUriForFileName,
      onFailure: onFailure,
      runTest: runTestFor(const MacroDataComputer(), [new MacroTestConfig()]));
}

class MacroTestConfig extends TestConfig {
  MacroTestConfig()
      : super(cfeMarker, 'cfe',
            explicitExperimentalFlags: {ExperimentalFlag.macros: true},
            packageConfigUri:
                Platform.script.resolve('data/package_config.json'));

  @override
  TestMacroExecutor customizeCompilerOptions(
      CompilerOptions options, TestData testData) {
    TestMacroExecutor macroExecutor = new TestMacroExecutor();
    options.macroExecutorProvider = () async => macroExecutor;
    return macroExecutor;
  }
}

class MacroDataComputer extends DataComputer<Features> {
  const MacroDataComputer();

  @override
  void computeMemberData(TestResultData testResultData, Member member,
      Map<Id, ActualData<Features>> actualMap,
      {bool? verbose}) {
    member.accept(new MacroDataExtractor(testResultData, actualMap));
  }

  @override
  void computeClassData(TestResultData testResultData, Class cls,
      Map<Id, ActualData<Features>> actualMap,
      {bool? verbose}) {
    new MacroDataExtractor(testResultData, actualMap).computeForClass(cls);
  }

  @override
  void computeLibraryData(TestResultData testResultData, Library library,
      Map<Id, ActualData<Features>> actualMap,
      {bool? verbose}) {
    new MacroDataExtractor(testResultData, actualMap)
        .computeForLibrary(library);
  }

  @override
  DataInterpreter<Features> get dataValidator =>
      const FeaturesDataInterpreter();
}

class Tags {
  static const String macrosAreAvailable = 'macrosAreAvailable';
  static const String macrosAreApplied = 'macrosAreApplied';
  static const String compilationSequence = 'compilationSequence';
  static const String declaredMacros = 'declaredMacros';
  static const String appliedMacros = 'appliedMacros';
  static const String macroClassIds = 'macroClassIds';
  static const String macroInstanceIds = 'macroInstanceIds';
}

String importUriToString(Uri importUri) {
  if (importUri.scheme == 'package') {
    return importUri.toString();
  } else if (importUri.scheme == 'dart') {
    return importUri.toString();
  } else {
    return importUri.pathSegments.last;
  }
}

String libraryToString(Library library) => importUriToString(library.importUri);

String strongComponentToString(Iterable<Uri> uris) {
  List<String> list = uris.map(importUriToString).toList();
  list.sort();
  return list.join('|');
}

class MacroDataExtractor extends CfeDataExtractor<Features> {
  final TestResultData testResultData;
  late final MacroDeclarationData macroDeclarationData;
  late final MacroApplicationData macroApplicationData;

  MacroDataExtractor(
      this.testResultData, Map<Id, ActualData<Features>> actualMap)
      : super(testResultData.compilerResult, actualMap) {
    macroDeclarationData = testResultData.compilerResult.kernelTargetForTesting!
        .loader.dataForTesting!.macroDeclarationData;
    macroApplicationData = testResultData.compilerResult.kernelTargetForTesting!
        .loader.dataForTesting!.macroApplicationData;
  }

  TestMacroExecutor get macroExecutor => testResultData.customData;

  LibraryMacroApplicationData? getLibraryMacroApplicationData(Library library) {
    for (MapEntry<LibraryBuilder, LibraryMacroApplicationData> entry
        in macroApplicationData.libraryData.entries) {
      if (entry.key.library == library) {
        return entry.value;
      }
    }
    return null;
  }

  ClassMacroApplicationData? getClassMacroApplicationData(Class cls) {
    LibraryMacroApplicationData? applicationData =
        getLibraryMacroApplicationData(cls.enclosingLibrary);
    if (applicationData != null) {
      for (MapEntry<ClassBuilder, ClassMacroApplicationData> entry
          in applicationData.classData.entries) {
        if (entry.key.cls == cls) {
          return entry.value;
        }
      }
    }
    return null;
  }

  MacroApplications? getClassMacroApplications(Class cls) {
    return getClassMacroApplicationData(cls)?.classApplications;
  }

  MacroApplications? getMemberMacroApplications(Member member) {
    Class? enclosingClass = member.enclosingClass;
    Map<MemberBuilder, MacroApplications>? memberApplications;
    if (enclosingClass != null) {
      memberApplications =
          getClassMacroApplicationData(enclosingClass)?.memberApplications;
    } else {
      memberApplications =
          getLibraryMacroApplicationData(member.enclosingLibrary)
              ?.memberApplications;
    }
    if (memberApplications != null) {
      for (MapEntry<MemberBuilder, MacroApplications> entry
          in memberApplications.entries) {
        if (entry.key.member == member) {
          return entry.value;
        }
      }
    }
    return null;
  }

  void registerMacroApplications(
      Features features, MacroApplications? macroApplications) {
    if (macroApplications != null) {
      for (MacroApplication application in macroApplications.macros) {
        String className = application.classBuilder.name;
        String constructorName = application.constructorName == ''
            ? 'new'
            : application.constructorName;
        features.addElement(
            Tags.appliedMacros, '${className}.${constructorName}');
      }
    }
  }

  @override
  Features computeClassValue(Id id, Class node) {
    Features features = new Features();
    if (getClassMacroApplicationData(node) != null) {
      features.add(Tags.macrosAreApplied);
    }
    registerMacroApplications(features, getClassMacroApplications(node));
    return features;
  }

  @override
  Features computeLibraryValue(Id id, Library node) {
    Features features = new Features();
    if (macroDeclarationData.macrosAreAvailable) {
      features.add(Tags.macrosAreAvailable);
    }
    if (node == compilerResult.component!.mainMethod!.enclosingLibrary) {
      if (macroDeclarationData.compilationSequence != null) {
        features.markAsUnsorted(Tags.compilationSequence);
        for (List<Uri> component in macroDeclarationData.compilationSequence!) {
          features.addElement(
              Tags.compilationSequence, strongComponentToString(component));
        }
      }
      for (_MacroClassIdentifier id in macroExecutor.macroClasses) {
        features.addElement(Tags.macroClassIds, id.toText());
      }
      for (_MacroInstanceIdentifier id in macroExecutor.macroInstances) {
        features.addElement(Tags.macroInstanceIds, id.toText());
      }
    }
    List<String>? macroClasses =
        macroDeclarationData.macroDeclarations[node.importUri];
    if (macroClasses != null) {
      for (String clsName in macroClasses) {
        features.addElement(Tags.declaredMacros, clsName);
      }
    }
    if (getLibraryMacroApplicationData(node) != null) {
      features.add(Tags.macrosAreApplied);
    }

    return features;
  }

  @override
  Features computeMemberValue(Id id, Member node) {
    Features features = new Features();
    registerMacroApplications(features, getMemberMacroApplications(node));
    return features;
  }
}

class TestMacroExecutor implements MacroExecutor {
  List<_MacroClassIdentifier> macroClasses = [];
  List<_MacroInstanceIdentifier> macroInstances = [];

  @override
  Future<String> buildAugmentationLibrary(
      Iterable<MacroExecutionResult> macroResults) {
    // TODO: implement buildAugmentationLibrary
    throw UnimplementedError();
  }

  @override
  void close() {
    // TODO: implement close
  }

  @override
  Future<MacroExecutionResult> executeDeclarationsPhase(
      MacroInstanceIdentifier macro,
      Declaration declaration,
      TypeResolver typeResolver,
      ClassIntrospector classIntrospector) {
    // TODO: implement executeDeclarationsPhase
    throw UnimplementedError();
  }

  @override
  Future<MacroExecutionResult> executeDefinitionsPhase(
      MacroInstanceIdentifier macro,
      Declaration declaration,
      TypeResolver typeResolver,
      ClassIntrospector classIntrospector,
      TypeDeclarationResolver typeDeclarationResolver) {
    // TODO: implement executeDefinitionsPhase
    throw UnimplementedError();
  }

  @override
  Future<MacroExecutionResult> executeTypesPhase(
      MacroInstanceIdentifier macro, Declaration declaration) {
    // TODO: implement executeTypesPhase
    throw UnimplementedError();
  }

  @override
  Future<MacroInstanceIdentifier> instantiateMacro(
      MacroClassIdentifier macroClass,
      String constructor,
      Arguments arguments) async {
    _MacroInstanceIdentifier id = new _MacroInstanceIdentifier(
        macroClass as _MacroClassIdentifier, constructor, arguments);
    macroInstances.add(id);
    return id;
  }

  @override
  Future<MacroClassIdentifier> loadMacro(Uri library, String name) async {
    _MacroClassIdentifier id = new _MacroClassIdentifier(library, name);
    macroClasses.add(id);
    return id;
  }
}

class _MacroClassIdentifier implements MacroClassIdentifier {
  final Uri uri;
  final String className;

  _MacroClassIdentifier(this.uri, this.className);

  String toText() => '${importUriToString(uri)}/${className}';

  @override
  int get hashCode => uri.hashCode * 13 + className.hashCode * 17;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _MacroClassIdentifier &&
        uri == other.uri &&
        className == other.className;
  }

  @override
  String toString() => 'MacroClassIdentifier($uri,$className)';
}

class _MacroInstanceIdentifier implements MacroInstanceIdentifier {
  final _MacroClassIdentifier macroClass;
  final String constructor;
  final Arguments arguments;

  _MacroInstanceIdentifier(this.macroClass, this.constructor, this.arguments);

  String toText() => '${macroClass.toText()}/${constructor}()';
}
