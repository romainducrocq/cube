from ccc.abc_builtin_ast cimport AST #
from ccc.lexer_lexer cimport Token #
#
cdef void pretty_print_tokens(list[Token] tokens) #
cdef void pretty_print_ast(AST node) #
cdef void pretty_print_symbol_table() #
cdef void pretty_print_backend_symbol_table() #
cdef void pretty_print_asm_code(list[str] asm_code) #
#
