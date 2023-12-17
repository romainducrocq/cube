from ccc.lexer_lexer cimport Token
from ccc.parser_c_ast cimport CProgram

cdef CProgram parsing(list[Token] lex_tokens)
