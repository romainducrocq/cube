from ccc.parser_c_ast cimport CProgram
from ccc.lexer_lexer cimport Token

cdef CProgram parsing(list[Token] lex_tokens)
