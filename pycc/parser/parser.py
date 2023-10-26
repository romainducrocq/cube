from typing import Generator

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
    c_ast: AST = None
    next_token: Token = None

    def __init__(self, tokens: Generator[Token, None, None]):
        self.tokens: Generator[Token, None, None] = tokens

    def expect_next(self, expected_token: int) -> None:
        self.next_token = next(self.tokens)
        if self.next_token.token_kind != expected_token:
            raise ParserError(
                f"Expected token \"{expected_token}\" but found \"{self.next_token.token_kind}\"")

    def parse_identifier(self) -> TIdentifier:
        """ <identifier> ::= ? An identifier token ? """
        self.expect_next(TOKEN_KIND.identifier)
        return TIdentifier(self.next_token.token)

    def parse_int(self) -> TInt:
        """ <int> ::= ? A constant token ? """
        return TInt(int(self.next_token.token))

    def parse_constant(self) -> CConstant:
        """ <constant> ::= <int> """
        self.expect_next(TOKEN_KIND.constant)
        value: TInt = self.parse_int()
        return CConstant(value)

    def parse_exp(self) -> CExp:
        """ <exp> ::= <constant> """
        int_const: CConstant = self.parse_constant()
        return int_const

    def parse_statement(self) -> CStatement:
        """ <statement> ::= "return" <exp> ";" """
        self.expect_next(TOKEN_KIND.key_return)
        return_exp: CExp = self.parse_exp()
        self.expect_next(TOKEN_KIND.semicolon)
        return CReturn(return_exp)

    def parse_function_def(self) -> CFunctionDef:
        """ <function> ::= "int" <identifier> "(" "void" ")" "{" <statement> "}" """
        self.expect_next(TOKEN_KIND.key_int)
        name: TIdentifier = self.parse_identifier()
        self.expect_next(TOKEN_KIND.parenthesis_open)
        self.expect_next(TOKEN_KIND.key_void)
        self.expect_next(TOKEN_KIND.parenthesis_close)
        self.expect_next(TOKEN_KIND.brace_open)
        body: CStatement = self.parse_statement()
        self.expect_next(TOKEN_KIND.brace_close)
        return CFunction(name, body)

    def parse_program(self) -> None:
        """ <program> ::= <function> """
        function_def: CFunctionDef = self.parse_function_def()
        self.c_ast = CProgram(function_def)


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
