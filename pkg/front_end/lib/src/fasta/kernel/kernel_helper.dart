// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library fasta.kernel_target;

import 'package:kernel/ast.dart';
import 'package:kernel/clone.dart' show CloneVisitorNotMembers;
import 'package:kernel/type_algebra.dart' show Substitution;
import 'package:kernel/type_environment.dart';

import '../builder/library_builder.dart';
import '../messages.dart';

/// Data for clone default values for synthesized function nodes once the
/// original default values have been computed.
///
/// This is used for constructors in unnamed mixin application, which are
/// created from the constructors in the superclass, and for tear off lowerings
/// for redirecting factories, which are created from the effective target
/// constructor.
class DelayedDefaultValueCloner {
  /// Type parameter map from type parameters in scope [_original] to types
  /// in scope of [_synthesized].
  // TODO(johnniwinther): Is this ever needed? Should occurrence of type
  //  variable types in default values be a compile time error?
  final Map<TypeParameter, DartType> _typeSubstitution;

  /// The original function node.
  final FunctionNode _original;

  /// The synthesized function node.
  final FunctionNode _synthesized;

  /// If `true`, the [_synthesized] is guaranteed to have the same parameters in
  /// the same order as [_original]. Otherwise [_original] is only guaranteed to
  /// be callable from [_synthesized], meaning that is has at most the same
  /// number of positional parameters and a, possibly reordered, subset of the
  /// named parameters.
  final bool identicalSignatures;

  final List<int?>? _positionalSuperParameters;

  final List<String>? _namedSuperParameters;

  bool isOutlineNode;

  final LibraryBuilder _libraryBuilder;

  CloneVisitorNotMembers? _cloner;

  DelayedDefaultValueCloner(
      this._typeSubstitution, this._original, this._synthesized,
      {this.identicalSignatures: true,
      List<int?>? positionalSuperParameters: null,
      List<String>? namedSuperParameters: null,
      this.isOutlineNode: false,
      required LibraryBuilder libraryBuilder})
      : _positionalSuperParameters = positionalSuperParameters,
        _namedSuperParameters = namedSuperParameters,
        _libraryBuilder = libraryBuilder,
        // Check that [positionalSuperParameters] and [namedSuperParameters] are
        // provided or omitted together.
        assert((positionalSuperParameters == null) ==
            (namedSuperParameters == null)),
        assert(positionalSuperParameters == null ||
            () {
              // Check that [positionalSuperParameters] is sorted if it's
              // provided. The `null` values are allowed in-between the sorted
              // values.
              for (int i = -1, j = 0;
                  j < positionalSuperParameters.length;
                  j++) {
                int? currentValue = positionalSuperParameters[j];
                if (currentValue != null) {
                  if (i == -1 || positionalSuperParameters[i]! < currentValue) {
                    i = j;
                  } else {
                    return false;
                  }
                }
              }
              return true;
            }()),
        assert(namedSuperParameters == null ||
            () {
              // Check that [namedSuperParameters] are the subset of and in the
              // same order as the named parameters of [_synthesized].
              int superParameterIndex = 0;
              for (int namedParameterIndex = 0;
                  namedParameterIndex < _synthesized.namedParameters.length &&
                      superParameterIndex < namedSuperParameters.length;
                  namedParameterIndex++) {
                if (_synthesized.namedParameters[namedParameterIndex].name ==
                    namedSuperParameters[superParameterIndex]) {
                  ++superParameterIndex;
                }
              }
              return superParameterIndex == namedSuperParameters.length;
            }());

  void cloneDefaultValues(TypeEnvironment typeEnvironment) {
    // TODO(ahe): It is unclear if it is legal to use type variables in
    // default values, but Fasta is currently allowing it, and the VM
    // accepts it. If it isn't legal, the we can speed this up by using a
    // single cloner without substitution.

    // For mixin application constructors, the argument count is the same, but
    // for redirecting tear off lowerings, the argument count of the tear off
    // can be less than that of the redirection target or, in errors cases, be
    // unrelated.

    if (identicalSignatures) {
      assert(_positionalSuperParameters != null ||
          _synthesized.positionalParameters.length ==
              _original.positionalParameters.length);
      List<int?>? positionalSuperParameters = _positionalSuperParameters;
      for (int i = 0; i < _original.positionalParameters.length; i++) {
        if (positionalSuperParameters == null) {
          _cloneInitializer(_original.positionalParameters[i],
              _synthesized.positionalParameters[i]);
        } else if (i < positionalSuperParameters.length) {
          int? superParameterIndex = positionalSuperParameters[i];
          if (superParameterIndex != null) {
            VariableDeclaration originalParameter =
                _original.positionalParameters[i];
            VariableDeclaration synthesizedParameter =
                _synthesized.positionalParameters[superParameterIndex];
            _cloneDefaultValueForSuperParameters(
                originalParameter, synthesizedParameter, typeEnvironment);
          }
        }
      }

      assert(_namedSuperParameters != null ||
          _synthesized.namedParameters.length ==
              _original.namedParameters.length);
      List<String>? namedSuperParameters = _namedSuperParameters;
      int superParameterNameIndex = 0;
      Map<String, int> originalNamedParameterIndices = {};
      for (int i = 0; i < _original.namedParameters.length; i++) {
        originalNamedParameterIndices[_original.namedParameters[i].name!] = i;
      }
      for (int i = 0; i < _synthesized.namedParameters.length; i++) {
        if (namedSuperParameters == null) {
          _cloneInitializer(
              _original.namedParameters[i], _synthesized.namedParameters[i]);
        } else if (superParameterNameIndex < namedSuperParameters.length &&
            namedSuperParameters[superParameterNameIndex] ==
                _synthesized.namedParameters[i].name) {
          String superParameterName =
              namedSuperParameters[superParameterNameIndex];
          int? originalNamedParameterIndex =
              originalNamedParameterIndices[superParameterName];
          if (originalNamedParameterIndex != null) {
            VariableDeclaration originalParameter =
                _original.namedParameters[originalNamedParameterIndex];
            VariableDeclaration synthesizedParameter =
                _synthesized.namedParameters[i];
            _cloneDefaultValueForSuperParameters(
                originalParameter, synthesizedParameter, typeEnvironment);
          } else {
            // TODO(cstefantsova): Handle the erroneous case of missing names.
          }
          superParameterNameIndex++;
        }
      }
    } else {
      for (int i = 0; i < _synthesized.positionalParameters.length; i++) {
        VariableDeclaration synthesizedParameter =
            _synthesized.positionalParameters[i];
        if (i < _original.positionalParameters.length) {
          _cloneInitializer(
              _original.positionalParameters[i], synthesizedParameter);
        } else {
          // Error case: use `null` as initializer.
          synthesizedParameter.initializer = new NullLiteral()
            ..parent = synthesizedParameter;
        }
      }
      if (_synthesized.namedParameters.isNotEmpty) {
        Map<String, VariableDeclaration> originalParameters = {};
        for (int i = 0; i < _original.namedParameters.length; i++) {
          originalParameters[_original.namedParameters[i].name!] =
              _original.namedParameters[i];
        }
        for (int i = 0; i < _synthesized.namedParameters.length; i++) {
          VariableDeclaration synthesizedParameter =
              _synthesized.namedParameters[i];
          VariableDeclaration? originalParameter =
              originalParameters[synthesizedParameter.name!];
          if (originalParameter != null) {
            _cloneInitializer(originalParameter, synthesizedParameter);
          } else {
            // Error case: use `null` as initializer.
            synthesizedParameter.initializer = new NullLiteral()
              ..parent = synthesizedParameter;
          }
        }
      }
    }
  }

  void _cloneInitializer(VariableDeclaration originalParameter,
      VariableDeclaration clonedParameter) {
    if (originalParameter.initializer != null) {
      CloneVisitorNotMembers cloner = _cloner ??=
          new CloneVisitorNotMembers(typeSubstitution: _typeSubstitution);
      clonedParameter.initializer = cloner.clone(originalParameter.initializer!)
        ..parent = clonedParameter;
    }
  }

  void _cloneDefaultValueForSuperParameters(
      VariableDeclaration originalParameter,
      VariableDeclaration synthesizedParameter,
      TypeEnvironment typeEnvironment) {
    Member member = _synthesized.parent as Member;
    Expression? originalParameterInitializer = originalParameter.initializer;
    DartType? originalParameterInitializerType = originalParameterInitializer
        ?.getStaticType(new StaticTypeContext(member, typeEnvironment));
    DartType synthesizedParameterType = synthesizedParameter.type;
    if (originalParameterInitializerType != null &&
        typeEnvironment.isSubtypeOf(originalParameterInitializerType,
            synthesizedParameterType, SubtypeCheckMode.withNullabilities)) {
      _cloneInitializer(originalParameter, synthesizedParameter);
    } else {
      if (synthesizedParameterType.isPotentiallyNonNullable) {
        _libraryBuilder.addProblem(
            templateOptionalSuperParameterWithoutInitializer.withArguments(
                synthesizedParameter.type,
                synthesizedParameter.name!,
                _libraryBuilder.isNonNullableByDefault),
            synthesizedParameter.fileOffset,
            synthesizedParameter.name?.length ?? 1,
            _libraryBuilder.fileUri);
      }
    }
  }

  @override
  String toString() {
    return "DelayedDefaultValueCloner(original=${_original.parent}, "
        "synthesized=${_synthesized.parent})";
  }
}

class TypeDependency {
  final Member synthesized;
  final Member original;
  final Substitution substitution;
  final bool copyReturnType;

  TypeDependency(this.synthesized, this.original, this.substitution,
      {required this.copyReturnType});

  void copyInferred() {
    for (int i = 0; i < original.function!.positionalParameters.length; i++) {
      VariableDeclaration synthesizedParameter =
          synthesized.function!.positionalParameters[i];
      VariableDeclaration constructorParameter =
          original.function!.positionalParameters[i];
      synthesizedParameter.type =
          substitution.substituteType(constructorParameter.type);
    }
    for (int i = 0; i < original.function!.namedParameters.length; i++) {
      VariableDeclaration synthesizedParameter =
          synthesized.function!.namedParameters[i];
      VariableDeclaration originalParameter =
          original.function!.namedParameters[i];
      synthesizedParameter.type =
          substitution.substituteType(originalParameter.type);
    }
    if (copyReturnType) {
      synthesized.function!.returnType =
          substitution.substituteType(original.function!.returnType);
    }
  }
}
