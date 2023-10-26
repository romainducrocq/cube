from typing import Optional, Generator

from pycc.parser.__ast import *
from pycc.parser.lexer import TOKEN_KIND, Token

__all__ = [
    'parsing'
]


class ParserError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__()


class Parser:

    def __init__(self, tokens: Generator[Token, None, None]):
        self.c_ast: Optional[AST] = None
        self.next_token: Optional[Token] = None
        self.tokens: Generator[Token, None, None] = tokens

    def expect_next(self, expected_token: int) -> None:
        self.next_token = next(self.tokens)
        if self.next_token.token_kind != expected_token:
            raise ParserError(
                f"Expected token \"{expected_token}\" but found \"{self.next_token.token_kind}\"")

    def parse_identifier(self) -> str:
        """ <identifier> ::= ? An identifier token ? """
        self.expect_next(TOKEN_KIND.identifier)
        return self.next_token.token

    def parse_constant(self) -> CConstant:
        """ <int> ::= ? A constant token ? """
        self.expect_next(TOKEN_KIND.constant)
        return CConstant(int(self.next_token.token))

    def parse_expr(self) -> CExpr:
        """ <exp> ::= <int> """
        int_const: CConstant = self.parse_constant()
        return int_const

    def parse_statement(self) -> CStatement:
        """ <statement> ::= "return" <exp> ";" """
        self.expect_next(TOKEN_KIND.key_return)
        return_expr: CExpr = self.parse_expr()
        self.expect_next(TOKEN_KIND.semicolon)
        return CReturn(return_expr)

    def parse_function(self) -> CFunction:
        """ <function> ::= "int" <identifier> "(" "void" ")" "{" <statement> "}" """
        self.expect_next(TOKEN_KIND.key_int)
        identifier: str = self.parse_identifier()
        self.expect_next(TOKEN_KIND.parenthesis_open)
        self.expect_next(TOKEN_KIND.key_void)
        self.expect_next(TOKEN_KIND.parenthesis_close)
        self.expect_next(TOKEN_KIND.brace_open)
        body: CStatement = self.parse_statement()
        self.expect_next(TOKEN_KIND.brace_close)
        return CFunction(identifier, body)

    def parse_program(self) -> None:
        """ <program> ::= <function> """
        self.c_ast = self.parse_function()


def parsing(tokens: Generator[Token, None, None]) -> AST:

    parser = Parser(tokens)
    while True:
        try:
            parser.parse_program()

        except StopIteration:
            break

    if list(tokens):
        raise ParserError(
            "An error occurred in parsing, not all tokens were consumed")

    if not parser.c_ast:
        raise ParserError(
            "An error occurred in parsing, AST was not parsed")

    return parser.c_ast
