#!/bin/bash

PACKAGE_NAME="$(cat ../build/package_name.txt)"

LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
NC='\033[0m'

function file () {
    FILE=${1%.*}
    if [ -f "${FILE}" ]; then rm ${FILE}; fi
    echo "${FILE}"
}

function total () {
    echo "----------------------------------------------------------------------"
    RES="${PASS} / ${TOTAL}"
    if [ ${PASS} -eq ${TOTAL} ]; then
        RES="${LIGHT_GREEN}PASS: ${RES}${NC}"
    else
        RES="${LIGHT_RED}FAIL: ${RES}${NC}"
    fi
    echo -e "${RES}"
}

function CHECK_FAIL () {
    FILE=$(file ${1})

    ${PACKAGE_NAME} ${FILE}.c > /dev/null 2>&1
    RET_CCC=${?}
    if [ ${RET_CCC} -ne 0 ]; then
        RES="${LIGHT_GREEN}[y]"
        let PASS+=1
    else
        RES="${LIGHT_RED}[n]"
    fi
    echo -e "${RES} ${FILE}.c${NC} -> ${PACKAGE_NAME}: ${RET_CCC}"

    let TOTAL+=1
}

function CHECK_RET () {
    FILE=$(file ${1})

    gcc ${FILE}.c -o ${FILE} > /dev/null 2>&1
    ${FILE}
    RET_GCC=${?}
    rm ${FILE}

    RES=""
    ${PACKAGE_NAME} ${FILE}.c > /dev/null 2>&1
    RET_CCC=${?}
    if [ ${RET_CCC} -eq 0 ]; then
        ${FILE}
        RET_CCC=${?}
        rm ${FILE}

        if [ ${RET_GCC} -eq ${RET_CCC} ]; then
            RES="${LIGHT_GREEN}[y]"
            let PASS+=1
        else
            RES="${LIGHT_RED}[n]"
        fi
    else
        RES="${LIGHT_RED}[n]"
    fi
    echo -e "${RES} ${FILE}.c${NC} -> gcc: ${RET_GCC}, ${PACKAGE_NAME}: ${RET_CCC}"

    let TOTAL+=1
}

function 1_int_constants () {
    CHECK_FAIL 1_int_constants/invalid_lex/at_sign.c
    CHECK_FAIL 1_int_constants/invalid_lex/backslash.c
    CHECK_FAIL 1_int_constants/invalid_lex/backtick.c
    CHECK_FAIL 1_int_constants/invalid_lex/invalid_identifier_2.c
    CHECK_FAIL 1_int_constants/invalid_lex/invalid_identifier.c

    CHECK_FAIL 1_int_constants/invalid_parse/end_before_expr.c
    CHECK_FAIL 1_int_constants/invalid_parse/extra_junk.c
    CHECK_FAIL 1_int_constants/invalid_parse/invalid_function_name.c
    CHECK_FAIL 1_int_constants/invalid_parse/keyword_wrong_case.c
    CHECK_FAIL 1_int_constants/invalid_parse/misspelled_keyword.c
    CHECK_FAIL 1_int_constants/invalid_parse/no_semicolon.c
    CHECK_FAIL 1_int_constants/invalid_parse/not_expression.c
    CHECK_FAIL 1_int_constants/invalid_parse/space_in_keyword.c
    CHECK_FAIL 1_int_constants/invalid_parse/switched_parens.c
    CHECK_FAIL 1_int_constants/invalid_parse/unclosed_brace.c
    CHECK_FAIL 1_int_constants/invalid_parse/unclosed_paren.c

    CHECK_RET 1_int_constants/valid/multi_digit.c
    CHECK_RET 1_int_constants/valid/newlines.c
    CHECK_RET 1_int_constants/valid/no_newlines.c
    CHECK_RET 1_int_constants/valid/return_0.c
    CHECK_RET 1_int_constants/valid/return_2.c
    CHECK_RET 1_int_constants/valid/spaces.c
    CHECK_RET 1_int_constants/valid/tabs.c
}

function 2_unary_operators () {
    CHECK_FAIL 2_unary_operators/invalid_parse/missing_semicolon.c
    CHECK_FAIL 2_unary_operators/invalid_parse/missing_const.c
    CHECK_FAIL 2_unary_operators/invalid_parse/nested_missing_const.c
    CHECK_FAIL 2_unary_operators/invalid_parse/extra_paren.c
    CHECK_FAIL 2_unary_operators/invalid_parse/parenthesize_operand.c
    CHECK_FAIL 2_unary_operators/invalid_parse/unclosed_paren.c
    CHECK_FAIL 2_unary_operators/invalid_parse/wrong_order.c

    CHECK_RET 2_unary_operators/valid/redundant_parens.c
    CHECK_RET 2_unary_operators/valid/bitwise.c
    CHECK_RET 2_unary_operators/valid/parens_3.c
    CHECK_RET 2_unary_operators/valid/parens.c
    CHECK_RET 2_unary_operators/valid/neg.c
    CHECK_RET 2_unary_operators/valid/nested_ops.c
    CHECK_RET 2_unary_operators/valid/negate_int_max.c
    CHECK_RET 2_unary_operators/valid/bitwise_zero.c
    CHECK_RET 2_unary_operators/valid/neg_zero.c
    CHECK_RET 2_unary_operators/valid/nested_ops_2.c
    CHECK_RET 2_unary_operators/valid/parens_2.c
    CHECK_RET 2_unary_operators/valid/bitwise_int_min.c
}

function 3_binary_operators () {
    CHECK_FAIL 3_binary_operators/invalid_parse/imbalanced_paren.c
    CHECK_FAIL 3_binary_operators/invalid_parse/missing_second_op.c
    CHECK_FAIL 3_binary_operators/invalid_parse/double_operation.c
    CHECK_FAIL 3_binary_operators/invalid_parse/no_semicolon.c
    CHECK_FAIL 3_binary_operators/invalid_parse/missing_first_op.c
    CHECK_FAIL 3_binary_operators/invalid_parse/missing_open_paren.c
    CHECK_FAIL 3_binary_operators/invalid_parse/misplaced_semicolon.c
    CHECK_FAIL 3_binary_operators/invalid_parse/bitwise_double_operator.c
    CHECK_FAIL 3_binary_operators/invalid_parse/malformed_paren.c

    CHECK_RET 3_binary_operators/valid/associativity_2.c
    CHECK_RET 3_binary_operators/valid/associativity_and_precedence.c
    CHECK_RET 3_binary_operators/valid/sub.c
    CHECK_RET 3_binary_operators/valid/bitwise_shiftl.c
    CHECK_RET 3_binary_operators/valid/bitwise_shift_associativity_2.c
    CHECK_RET 3_binary_operators/valid/bitwise_shift_associativity.c
    CHECK_RET 3_binary_operators/valid/mod.c
    CHECK_RET 3_binary_operators/valid/div_neg.c
    CHECK_RET 3_binary_operators/valid/associativity_3.c
    CHECK_RET 3_binary_operators/valid/parens.c
    CHECK_RET 3_binary_operators/valid/bitwise_and.c
    CHECK_RET 3_binary_operators/valid/bitwise_shiftr.c
    CHECK_RET 3_binary_operators/valid/bitwise_xor.c
    CHECK_RET 3_binary_operators/valid/unop_parens.c
    CHECK_RET 3_binary_operators/valid/sub_neg.c
    CHECK_RET 3_binary_operators/valid/bitwise_shift_precedence.c
    CHECK_RET 3_binary_operators/valid/add.c
    CHECK_RET 3_binary_operators/valid/bitwise_precedence.c
    CHECK_RET 3_binary_operators/valid/mult.c
    CHECK_RET 3_binary_operators/valid/unop_add.c
    CHECK_RET 3_binary_operators/valid/precedence.c
    CHECK_RET 3_binary_operators/valid/bitwise_or.c
    CHECK_RET 3_binary_operators/valid/associativity.c
    CHECK_RET 3_binary_operators/valid/div.c
}

function 4_logical_and_relational_operators () {
    CHECK_FAIL 4_logical_and_relational_operators/invalid_parse/missing_semicolon.c
    CHECK_FAIL 4_logical_and_relational_operators/invalid_parse/missing_const.c
    CHECK_FAIL 4_logical_and_relational_operators/invalid_parse/unary_missing_semicolon.c
    CHECK_FAIL 4_logical_and_relational_operators/invalid_parse/missing_second_op.c
    CHECK_FAIL 4_logical_and_relational_operators/invalid_parse/missing_first_op.c
    CHECK_FAIL 4_logical_and_relational_operators/invalid_parse/missing_operand.c

    CHECK_RET 4_logical_and_relational_operators/valid/gt_true.c
    CHECK_RET 4_logical_and_relational_operators/valid/ge_true.c
    CHECK_RET 4_logical_and_relational_operators/valid/lt_true.c
    CHECK_RET 4_logical_and_relational_operators/valid/ne_false.c
    CHECK_RET 4_logical_and_relational_operators/valid/precedence_4.c
    CHECK_RET 4_logical_and_relational_operators/valid/precedence_2.c
    CHECK_RET 4_logical_and_relational_operators/valid/compare_arithmetic_results.c
    CHECK_RET 4_logical_and_relational_operators/valid/nested_ops.c
    CHECK_RET 4_logical_and_relational_operators/valid/multi_short_circuit.c
    CHECK_RET 4_logical_and_relational_operators/valid/or_true.c
    CHECK_RET 4_logical_and_relational_operators/valid/or_short_circuit.c
    CHECK_RET 4_logical_and_relational_operators/valid/not_sum_2.c
    CHECK_RET 4_logical_and_relational_operators/valid/and_false.c
    CHECK_RET 4_logical_and_relational_operators/valid/gt_false.c
    CHECK_RET 4_logical_and_relational_operators/valid/precedence_3.c
    CHECK_RET 4_logical_and_relational_operators/valid/bitwise_precedence.c
    CHECK_RET 4_logical_and_relational_operators/valid/precedence.c
    CHECK_RET 4_logical_and_relational_operators/valid/ge_false.c
    CHECK_RET 4_logical_and_relational_operators/valid/and_true.c
    CHECK_RET 4_logical_and_relational_operators/valid/eq_precedence.c
    CHECK_RET 4_logical_and_relational_operators/valid/and_short_circuit.c
    CHECK_RET 4_logical_and_relational_operators/valid/eq_true.c
    CHECK_RET 4_logical_and_relational_operators/valid/ne_true.c
    CHECK_RET 4_logical_and_relational_operators/valid/eq_false.c
    CHECK_RET 4_logical_and_relational_operators/valid/not_sum.c
    CHECK_RET 4_logical_and_relational_operators/valid/precedence_5.c
    CHECK_RET 4_logical_and_relational_operators/valid/or_false.c
    CHECK_RET 4_logical_and_relational_operators/valid/le_true.c
    CHECK_RET 4_logical_and_relational_operators/valid/operate_on_booleans.c
    CHECK_RET 4_logical_and_relational_operators/valid/not.c
    CHECK_RET 4_logical_and_relational_operators/valid/le_false.c
    CHECK_RET 4_logical_and_relational_operators/valid/associativity.c
    CHECK_RET 4_logical_and_relational_operators/valid/not_zero.c
    CHECK_RET 4_logical_and_relational_operators/valid/lt_false.c
}

function 5_local_variables () {
    CHECK_FAIL 5_local_variables/invalid_parse/missing_semicolon.c
    CHECK_FAIL 5_local_variables/invalid_parse/invalid_type.c
    CHECK_FAIL 5_local_variables/invalid_parse/compound_initializer.c
    CHECK_FAIL 5_local_variables/invalid_parse/declare_keyword_as_var.c
    CHECK_FAIL 5_local_variables/invalid_parse/invalid_specifier.c
    CHECK_FAIL 5_local_variables/invalid_parse/invalid_variable_name.c
    CHECK_FAIL 5_local_variables/invalid_parse/compound_invalid_operator.c
    CHECK_FAIL 5_local_variables/invalid_parse/malformed_less_equal.c
    CHECK_FAIL 5_local_variables/invalid_parse/return_in_assignment.c
    CHECK_FAIL 5_local_variables/invalid_parse/malformed_not_equal.c

    CHECK_FAIL 5_local_variables/invalid_semantics/declared_after_use.c
    CHECK_FAIL 5_local_variables/invalid_semantics/invalid_lvalue.c
    CHECK_FAIL 5_local_variables/invalid_semantics/redefine.c
    CHECK_FAIL 5_local_variables/invalid_semantics/mixed_precedence_assignment.c
    CHECK_FAIL 5_local_variables/invalid_semantics/invalid_lvalue_2.c
    CHECK_FAIL 5_local_variables/invalid_semantics/undeclared_var.c
    CHECK_FAIL 5_local_variables/invalid_semantics/use_then_redefine.c
    CHECK_FAIL 5_local_variables/invalid_semantics/undeclared_var_and.c
    CHECK_FAIL 5_local_variables/invalid_semantics/compound_initializer.c
    CHECK_FAIL 5_local_variables/invalid_semantics/undeclared_var_compare.c
    CHECK_FAIL 5_local_variables/invalid_semantics/compound_invalid_lvalue.c
    CHECK_FAIL 5_local_variables/invalid_semantics/undeclared_var_unary.c

    CHECK_RET 5_local_variables/valid/compound_bitwise_and.c
    CHECK_RET 5_local_variables/valid/assign_val_in_initializer.c
    CHECK_RET 5_local_variables/valid/compound_bitwise_shiftl.c
    CHECK_RET 5_local_variables/valid/unused_exp.c
    CHECK_RET 5_local_variables/valid/short_circuit_and_fail.c
    CHECK_RET 5_local_variables/valid/compound_mod.c
    CHECK_RET 5_local_variables/valid/use_val_in_own_initializer.c
    CHECK_RET 5_local_variables/valid/empty_function_body.c
    CHECK_RET 5_local_variables/valid/compound_bitwise_or.c
    CHECK_RET 5_local_variables/valid/null_then_return.c
    CHECK_RET 5_local_variables/valid/mixed_precedence_assignment.c
    CHECK_RET 5_local_variables/valid/bitwise_shiftr_assign.c
    CHECK_RET 5_local_variables/valid/allocate_temps_and_vars.c
    CHECK_RET 5_local_variables/valid/exp_then_declaration.c
    CHECK_RET 5_local_variables/valid/use_assignment_result.c
    CHECK_RET 5_local_variables/valid/assign.c
    CHECK_RET 5_local_variables/valid/bitwise_and_vars.c
    CHECK_RET 5_local_variables/valid/compound_assignment_chained.c
    CHECK_RET 5_local_variables/valid/compound_divide.c
    CHECK_RET 5_local_variables/valid/return_var.c
    CHECK_RET 5_local_variables/valid/compound_bitwise_xor.c
    CHECK_RET 5_local_variables/valid/null_statement.c
    CHECK_RET 5_local_variables/valid/short_circuit_or.c
    CHECK_RET 5_local_variables/valid/non_short_circuit_or.c
    CHECK_RET 5_local_variables/valid/local_var_missing_return.c
    CHECK_RET 5_local_variables/valid/compound_assignment_use_result.c
    CHECK_RET 5_local_variables/valid/bitwise_shiftl_variable.c
    CHECK_RET 5_local_variables/valid/compound_multiply.c
    CHECK_RET 5_local_variables/valid/compound_minus.c
    CHECK_RET 5_local_variables/valid/compound_plus.c
    CHECK_RET 5_local_variables/valid/compound_bitwise_shiftr.c
    CHECK_RET 5_local_variables/valid/assignment_in_initializer.c
    CHECK_RET 5_local_variables/valid/add_variables.c
    CHECK_RET 5_local_variables/valid/assignment_lowest_precedence.c
}

function 6_statements_and_conditional_expressions () {
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_lex/goto_bad_label.c

    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/declaration_as_statement.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/malformed_ternary_2.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/if_no_parens.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/goto_label_without_statement.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/mismatched_nesting.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/wrong_ternary_delimiter.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/malformed_ternary.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/if_assignment.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/incomplete_ternary.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_parse/empty_if_body.c

    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_semantics/invalid_var_in_if.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_semantics/goto_missing_label.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_semantics/ternary_assign.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_semantics/duplicate_labels.c
    CHECK_FAIL 6_statements_and_conditional_expressions/invalid_semantics/undeclared_var_in_ternary.c

    CHECK_RET 6_statements_and_conditional_expressions/valid/compound_if_expression.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/if_nested_4.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/if_nested_2.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/if_nested_5.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/nested_ternary_2.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/goto_backwards.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/goto_label_main_2.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/if_nested.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/rh_assignment.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/binary_false_condition.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/if_taken.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/bitwise_ternary.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/goto_nested_label.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/ternary_middle_assignment.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/goto_label_and_var.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/goto_label.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/nested_ternary.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/ternary_middle_binop.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/multiple_if.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/if_nested_3.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/goto_after_declaration.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/binary_condition.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/else.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/ternary_short_circuit_2.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/ternary.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/ternary_short_circuit.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/assign_ternary.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/goto_label_main.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/ternary_rh_binop.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/if_null_body.c
    CHECK_RET 6_statements_and_conditional_expressions/valid/if_not_taken.c
}

function 7_compound_statements () {
    CHECK_FAIL 7_compound_statements/invalid_parse/missing_semicolon.c
    CHECK_FAIL 7_compound_statements/invalid_parse/missing_brace.c
    CHECK_FAIL 7_compound_statements/invalid_parse/ternary_blocks.c
    CHECK_FAIL 7_compound_statements/invalid_parse/extra_brace.c

    CHECK_FAIL 7_compound_statements/invalid_semantics/double_define.c
    CHECK_FAIL 7_compound_statements/invalid_semantics/out_of_scope.c
    CHECK_FAIL 7_compound_statements/invalid_semantics/use_before_declare.c
    CHECK_FAIL 7_compound_statements/invalid_semantics/goto_use_before_declare.c
    CHECK_FAIL 7_compound_statements/invalid_semantics/duplicate_labels_different_scopes.c
    CHECK_FAIL 7_compound_statements/invalid_semantics/double_define_after_scope.c

    CHECK_RET 7_compound_statements/valid/multiple_vars_same_name.c
    CHECK_RET 7_compound_statements/valid/hidden_then_visible.c
    CHECK_RET 7_compound_statements/valid/hidden_variable.c
    CHECK_RET 7_compound_statements/valid/use_in_inner_scope.c
    CHECK_RET 7_compound_statements/valid/goto_before_declaration.c
    CHECK_RET 7_compound_statements/valid/assign_to_self_2.c
    CHECK_RET 7_compound_statements/valid/declaration_only.c
    CHECK_RET 7_compound_statements/valid/compound_subtract_in_block.c
    CHECK_RET 7_compound_statements/valid/assign_to_self.c
    CHECK_RET 7_compound_statements/valid/nested_if.c
    CHECK_RET 7_compound_statements/valid/similar_var_names.c
    CHECK_RET 7_compound_statements/valid/goto_inner_scope.c
    CHECK_RET 7_compound_statements/valid/empty_blocks.c
    CHECK_RET 7_compound_statements/valid/inner_uninitialized.c
}

function 8_loops () {
    CHECK_FAIL 8_loops/invalid_parse/while_missing_paren.c
    CHECK_FAIL 8_loops/invalid_parse/invalid_for_declaration.c
    CHECK_FAIL 8_loops/invalid_parse/statement_in_condition.c
    CHECK_FAIL 8_loops/invalid_parse/decl_as_loop_body.c
    CHECK_FAIL 8_loops/invalid_parse/missing_for_header_clause.c
    CHECK_FAIL 8_loops/invalid_parse/paren_mismatch.c
    CHECK_FAIL 8_loops/invalid_parse/compound_assignment_invalid_decl.c
    CHECK_FAIL 8_loops/invalid_parse/extra_for_header_clause.c
    CHECK_FAIL 8_loops/invalid_parse/do_while_empty_parens.c
    CHECK_FAIL 8_loops/invalid_parse/do_missing_semicolon.c

    CHECK_FAIL 8_loops/invalid_semantics/break_not_in_loop.c
    CHECK_FAIL 8_loops/invalid_semantics/continue_not_in_loop.c
    CHECK_FAIL 8_loops/invalid_semantics/out_of_scope_loop_variable.c
    CHECK_FAIL 8_loops/invalid_semantics/out_of_scope_do_loop.c

    CHECK_RET 8_loops/valid/multi_break.c
    CHECK_RET 8_loops/valid/do_while.c
    CHECK_RET 8_loops/valid/goto_loop_body.c
    CHECK_RET 8_loops/valid/for.c
    CHECK_RET 8_loops/valid/continue_empty_post.c
    CHECK_RET 8_loops/valid/empty_loop_body.c
    CHECK_RET 8_loops/valid/for_decl.c
    CHECK_RET 8_loops/valid/nested_continue.c
    CHECK_RET 8_loops/valid/multi_continue_same_loop.c
    CHECK_RET 8_loops/valid/break.c
    CHECK_RET 8_loops/valid/for_absent_post.c
    CHECK_RET 8_loops/valid/for_nested_shadow.c
    CHECK_RET 8_loops/valid/for_shadow.c
    CHECK_RET 8_loops/valid/while.c
    CHECK_RET 8_loops/valid/for_absent_condition.c
    CHECK_RET 8_loops/valid/goto_bypass_condition.c
    CHECK_RET 8_loops/valid/null_for_header.c
    CHECK_RET 8_loops/valid/break_immediate.c
    CHECK_RET 8_loops/valid/do_while_break_immediate.c
    CHECK_RET 8_loops/valid/nested_loop.c
    CHECK_RET 8_loops/valid/continue.c
    CHECK_RET 8_loops/valid/empty_expression.c
    CHECK_RET 8_loops/valid/nested_break.c
    CHECK_RET 8_loops/valid/compound_assignment_for_loop.c
}

function 9_functions () {
    echo -n ""
}

function tests () {
    1_int_constants
    2_unary_operators
    3_binary_operators
    4_logical_and_relational_operators
    5_local_variables
    6_statements_and_conditional_expressions
    7_compound_statements
    8_loops
    9_functions
}

PASS=0
TOTAL=0
cd ../../tests/
tests
total
