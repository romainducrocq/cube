from ccc.parser_c_ast cimport CVariableDeclaration, CFunctionDeclaration, CFunctionCall, CVar

cdef void checktype_function_call_expression(CFunctionCall node)
cdef void checktype_var_expression(CVar node)
cdef void checktype_params(CFunctionDeclaration node)
cdef void checktype_function_declaration(CFunctionDeclaration node)
cdef void checktype_file_scope_variable_declaration(CVariableDeclaration node)
cdef void checktype_block_scope_variable_declaration(CVariableDeclaration node)
cdef void init_check_types()
