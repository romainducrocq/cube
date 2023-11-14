from ccc.util_ast cimport AST
from ccc.parser_lexer cimport Token

cpdef AST parsing(list[Token] lex_tokens)