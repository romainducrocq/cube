from ccc.parser_c_ast cimport CVariableDeclaration, CFunctionDeclaration, CFunctionCall, CVar
from ccc.semantic_symbol_table cimport Symbol


cdef dict[str, Symbol] symbol_table

cdef void checktype_function_call_expression(CFunctionCall node)
cdef void checktype_var_expression(CVar node)
cdef void checktype_params(CFunctionDeclaration node)
cdef void checktype_function_declaration(CFunctionDeclaration node)
cdef void checktype_file_scope_variable_declaration(CVariableDeclaration node)
cdef void checktype_block_scope_variable_declaration(CVariableDeclaration node)
cdef void init_check_types()
