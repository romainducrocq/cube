from ccc.parser_c_ast cimport AST
from ccc.parser_lexer cimport Token

cdef AST parsing(list[Token] lex_tokens)
