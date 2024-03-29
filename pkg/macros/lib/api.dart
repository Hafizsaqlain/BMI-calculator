// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// The actual functionality exposed by this package is implemented in
// "dart:_macros", since the version used by precompiled SDK binaries must
// match exactly the version a user gets in their local version solve. This
// package exists as a shell to expose that internal API to outside code, with
// a versioning mechanism that is separate from the SDK itself.
//
// There are both public and private libraries as a part of `dart:_macros`, we
// only want to expose the public portions from this library, and use explicit
// shows to do that.

export 'dart:_macros'
    show
        Annotatable,
        Builder,
        ClassDeclaration,
        ClassDeclarationsMacro,
        ClassDefinitionMacro,
        ClassTypeBuilder,
        ClassTypesMacro,
        Code,
        CodeKind,
        CommentCode,
        ConstructorDeclaration,
        ConstructorDeclarationsMacro,
        ConstructorDefinitionBuilder,
        ConstructorDefinitionMacro,
        ConstructorMetadataAnnotation,
        ConstructorTypesMacro,
        Declaration,
        DeclarationAsTarget,
        DeclarationBuilder,
        DeclarationCode,
        DeclarationDiagnosticTarget,
        DeclarationPhaseIntrospector,
        DefinitionBuilder,
        DefinitionPhaseIntrospector,
        Diagnostic,
        DiagnosticException,
        DiagnosticMessage,
        DiagnosticTarget,
        EnumDeclaration,
        EnumDeclarationBuilder,
        EnumDeclarationsMacro,
        EnumDefinitionBuilder,
        EnumDefinitionMacro,
        EnumTypeBuilder,
        EnumTypesMacro,
        EnumValueDeclaration,
        EnumValueDeclarationsMacro,
        EnumValueDefinitionBuilder,
        EnumValueDefinitionMacro,
        EnumValueTypesMacro,
        ExpressionCode,
        ExtensionDeclaration,
        ExtensionDeclarationsMacro,
        ExtensionDefinitionMacro,
        ExtensionTypeDeclaration,
        ExtensionTypeDeclarationsMacro,
        ExtensionTypeDefinitionMacro,
        ExtensionTypesMacro,
        ExtensionTypeTypesMacro,
        FieldDeclaration,
        FieldDeclarationsMacro,
        FieldDefinitionMacro,
        FieldTypesMacro,
        FormalParameter,
        FormalParameterDeclaration,
        FunctionBodyCode,
        FunctionDeclaration,
        FunctionDeclarationsMacro,
        FunctionDefinitionBuilder,
        FunctionDefinitionMacro,
        FunctionTypeAnnotation,
        FunctionTypeAnnotationCode,
        FunctionTypesMacro,
        Identifier,
        IdentifierMetadataAnnotation,
        InterfaceTypesBuilder,
        LanguageVersion,
        Library,
        LibraryDeclarationsMacro,
        LibraryDefinitionBuilder,
        LibraryDefinitionMacro,
        LibraryTypesMacro,
        Macro,
        MacroException,
        MacroImplementationException,
        MacroIntrospectionCycleException,
        MacroTarget,
        MemberDeclaration,
        MemberDeclarationBuilder,
        MetadataAnnotation,
        MetadataAnnotationAsTarget,
        MetadataAnnotationDiagnosticTarget,
        MethodDeclaration,
        MethodDeclarationsMacro,
        MethodDefinitionMacro,
        MethodTypesMacro,
        MixinDeclaration,
        MixinDeclarationsMacro,
        MixinDefinitionMacro,
        MixinTypeBuilder,
        MixinTypesBuilder,
        MixinTypesMacro,
        NamedStaticType,
        NamedTypeAnnotation,
        NamedTypeAnnotationCode,
        NullableTypeAnnotationCode,
        OmittedTypeAnnotation,
        OmittedTypeAnnotationCode,
        ParameterCode,
        ParameterizedTypeDeclaration,
        RawCode,
        RawTypeAnnotationCode,
        RecordFieldDeclaration,
        RecordFieldCode,
        RecordTypeAnnotation,
        RecordTypeAnnotationCode,
        Severity,
        StaticType,
        TypeAliasDeclaration,
        TypeAnnotation,
        TypeAnnotationAsTarget,
        TypeAnnotationCode,
        TypeAnnotationDiagnosticTarget,
        TypeBuilder,
        TypeDeclaration,
        TypeDefinitionBuilder,
        TypeParameter,
        TypeParameterCode,
        TypeParameterDeclaration,
        TypePhaseIntrospector,
        UnexpectedMacroException,
        VariableDeclaration,
        VariableDeclarationsMacro,
        VariableDefinitionBuilder,
        VariableDefinitionMacro,
        VariableTypesMacro;
