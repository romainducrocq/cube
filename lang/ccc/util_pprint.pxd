from ccc.lexer_lexer cimport Token #
from ccc.abc_builtin_ast cimport AST #
#
cdef void pretty_print_tokens(list[Token] tokens) #
cdef void pretty_print_ast(AST node) #
cdef void pretty_print_symbol_table() #
cdef void pretty_print_asm_code(list[str] asm_code) #
#
