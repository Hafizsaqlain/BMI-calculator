// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'assignment_test.dart' as assignment;
import 'ast_rewrite_test.dart' as ast_rewrite;
import 'augmentation_import_test.dart' as augmentation_import;
import 'await_expression_test.dart' as await_expression;
import 'binary_expression_test.dart' as binary_expression;
import 'class_alias_test.dart' as class_alias;
import 'class_test.dart' as class_resolution;
import 'comment_test.dart' as comment;
import 'constant_test.dart' as constant;
import 'constructor_reference_test.dart' as constructor_reference;
import 'constructor_test.dart' as constructor;
import 'enum_test.dart' as enum_resolution;
import 'export_test.dart' as export_;
import 'extension_method_test.dart' as extension_method;
import 'extension_override_test.dart' as extension_override;
import 'field_formal_parameter_test.dart' as field_formal_parameter;
import 'field_test.dart' as field;
import 'for_element_test.dart' as for_element;
import 'for_statement_test.dart' as for_in;
import 'function_declaration_test.dart' as function_declaration;
import 'function_expression_invocation_test.dart'
    as function_expression_invocation;
import 'function_reference_test.dart' as function_reference;
import 'function_type_alias_test.dart' as function_type_alias;
import 'generic_function_type_test.dart' as generic_function_type;
import 'generic_type_alias_test.dart' as generic_type_alias;
import 'if_element_test.dart' as if_element;
import 'if_statement_test.dart' as if_statement;
import 'index_expression_test.dart' as index_expression;
import 'instance_creation_test.dart' as instance_creation;
import 'instance_member_inference_class_test.dart'
    as instance_member_inference_class;
import 'instance_member_inference_mixin_test.dart'
    as instance_member_inference_mixin;
import 'interpolation_string_test.dart' as interpolation_string;
import 'language_version_test.dart' as language_version;
import 'library_element_test.dart' as library_element;
import 'library_import_prefix_test.dart' as library_import_prefix;
import 'library_import_test.dart' as library_import;
import 'local_function_test.dart' as local_function;
import 'local_variable_test.dart' as local_variable;
import 'macro_test.dart' as macro;
import 'metadata_test.dart' as metadata;
import 'method_declaration_test.dart' as method_declaration;
import 'method_invocation_test.dart' as method_invocation;
import 'mixin_test.dart' as mixin_resolution;
import 'namespace_test.dart' as namespace;
import 'node_text_expectations.dart';
import 'non_nullable_bazel_workspace_test.dart' as non_nullable_bazel_workspace;
import 'non_nullable_test.dart' as non_nullable;
import 'optional_const_test.dart' as optional_const;
import 'part_test.dart' as part_;
import 'postfix_expression_test.dart' as postfix_expression;
import 'prefix_element_test.dart' as prefix_element;
import 'prefix_expression_test.dart' as prefix_expression;
import 'prefixed_identifier_test.dart' as prefixed_identifier;
import 'property_access_test.dart' as property_access;
import 'simple_identifier_test.dart' as simple_identifier;
import 'super_formal_parameter_test.dart' as super_formal_parameter;
import 'top_level_variable_test.dart' as top_level_variable;
import 'top_type_inference_test.dart' as top_type_inference;
import 'try_statement_test.dart' as try_statement;
import 'type_inference/test_all.dart' as type_inference;
import 'type_literal_test.dart' as type_literal;
import 'type_name_test.dart' as type_name;
import 'variance_test.dart' as variance_test;
import 'yield_statement_test.dart' as yield_statement;

main() {
  defineReflectiveSuite(() {
    assignment.main();
    ast_rewrite.main();
    augmentation_import.main();
    await_expression.main();
    binary_expression.main();
    class_alias.main();
    class_resolution.main();
    comment.main();
    constant.main();
    constructor.main();
    constructor_reference.main();
    enum_resolution.main();
    export_.main();
    extension_method.main();
    extension_override.main();
    field_formal_parameter.main();
    field.main();
    for_element.main();
    for_in.main();
    function_declaration.main();
    function_expression_invocation.main();
    function_reference.main();
    function_type_alias.main();
    generic_function_type.main();
    generic_type_alias.main();
    if_element.main();
    if_statement.main();
    index_expression.main();
    instance_creation.main();
    instance_member_inference_class.main();
    instance_member_inference_mixin.main();
    interpolation_string.main();
    language_version.main();
    library_element.main();
    library_import_prefix.main();
    library_import.main();
    local_function.main();
    local_variable.main();
    macro.main();
    metadata.main();
    method_declaration.main();
    method_invocation.main();
    mixin_resolution.main();
    namespace.main();
    non_nullable_bazel_workspace.main();
    non_nullable.main();
    optional_const.main();
    part_.main();
    postfix_expression.main();
    prefix_element.main();
    prefix_expression.main();
    prefixed_identifier.main();
    property_access.main();
    simple_identifier.main();
    super_formal_parameter.main();
    top_level_variable.main();
    top_type_inference.main();
    try_statement.main();
    type_inference.main();
    type_literal.main();
    type_name.main();
    variance_test.main();
    yield_statement.main();
    defineReflectiveTests(UpdateNodeTextExpectations);
  }, name: 'resolution');
}
