from ccc.abc_builtin_ast cimport int32

from ccc.parser_c_ast cimport CVariableDeclaration, CFunctionDeclaration, CReturn
from ccc.parser_c_ast cimport CFunctionCall, CVar, CCast, CConstant, CAssignment
from ccc.parser_c_ast cimport CUnary, CBinary, CConditional, CConst

from ccc.semantic_symbol_table cimport Type

cdef bint is_same_type(Type type1, Type type2)
cdef bint is_type_signed(Type type1)
cdef bint is_const_signed(CConst node)
cdef int32 get_type_size(Type type1)
cdef void checktype_cast_expression(CCast node)
cdef void checktype_function_call_expression(CFunctionCall node)
cdef void checktype_var_expression(CVar node)
cdef void checktype_constant_expression(CConstant node)
cdef void checktype_assignment_expression(CAssignment node)
cdef void checktype_unary_expression(CUnary node)
cdef void checktype_binary_expression(CBinary node)
cdef void checktype_conditional_expression(CConditional node)
cdef void checktype_return_statement(CReturn node)
cdef void checktype_params(CFunctionDeclaration node)
cdef void checktype_function_declaration(CFunctionDeclaration node)
cdef void checktype_file_scope_variable_declaration(CVariableDeclaration node)
cdef void checktype_block_scope_variable_declaration(CVariableDeclaration node)
cdef void checktype_init_block_scope_variable_declaration(CVariableDeclaration node)
cdef void init_check_types()
