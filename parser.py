from typing import Generator

from __ast import *
from lexer import TOKEN_KIND, Token

__all__ = [
    'parsing'
]


class ParserError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__()


class Parser:
    ast: AST = None
    next_token: Token = None
    tokens: Generator[Token, None, None] = None

    def __init__(self, tokens: Generator[Token, None, None]):
        self.tokens = tokens

    def expect_next(self, expected_token: int) -> None:
        self.next_token = next(self.tokens)
        if self.next_token.token_kind != expected_token:
            raise ParserError(
                f"Expected token \"{expected_token}\" but found \"{self.next_token.token_kind}\"")

    def parse_identifier(self) -> str:
        """ <identifier> ::= ? An identifier token ? """
        self.expect_next(TOKEN_KIND.identifier)
        return self.next_token.token

    def parse_constant(self) -> Constant:
        """ <int> ::= ? A constant token ? """
        self.expect_next(TOKEN_KIND.constant)
        return Constant(int(self.next_token.token))

    def parse_expr(self) -> Expr:
        """ <exp> ::= <int> """
        int_const: Constant = self.parse_constant()
        return int_const

    def parse_statement(self) -> Statement:
        """ <statement> ::= "return" <exp> ";" """
        self.expect_next(TOKEN_KIND.key_return)
        return_expr: Expr = self.parse_expr()
        self.expect_next(TOKEN_KIND.semicolon)
        return Return(return_expr)

    def parse_function(self) -> Function:
        """ <function> ::= "int" <identifier> "(" "void" ")" "{" <statement> "}" """
        self.expect_next(TOKEN_KIND.key_int)
        identifier: str = self.parse_identifier()
        self.expect_next(TOKEN_KIND.parenthesis_open)
        self.expect_next(TOKEN_KIND.key_void)
        self.expect_next(TOKEN_KIND.parenthesis_close)
        self.expect_next(TOKEN_KIND.brace_open)
        body: Statement = self.parse_statement()
        self.expect_next(TOKEN_KIND.brace_close)
        return Function(identifier, body)

    def parse_program(self) -> None:
        """ <program> ::= <function> """
        self.ast = self.parse_function()


def parsing(tokens: Generator[Token, None, None]) -> AST:

    parser = Parser(tokens)
    while True:
        try:
            parser.parse_program()

        except StopIteration:
            break

    return parser.ast
