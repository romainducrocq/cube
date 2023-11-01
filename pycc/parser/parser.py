from typing import List

from pycc.util.__ast import *
from pycc.parser.c_ast import *
from pycc.parser.lexer import TOKEN_KIND, Token

__all__ = [
    'parsing'
]


class ParserError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(ParserError, self).__init__(message)


class Parser:
    c_ast: AST = None
    next_token: Token = None
    peek_token: Token = None

    def __init__(self, tokens: List[Token]):
        self.tokens: List[Token] = tokens

    def next(self) -> Token:
        try:
            self.next_token = self.tokens.pop(0)
            return self.next_token
        except IndexError:
            raise StopIteration

    def peek(self) -> Token:
        try:
            self.peek_token = self.tokens[0]
            return self.peek_token
        except IndexError:
            raise StopIteration

    @staticmethod
    def expect_next(next_token: Token, *expected_tokens: int) -> None:
        if next_token.token_kind not in expected_tokens:
            raise ParserError(
                f"""Expected token in kinds { tuple([
                    list(TOKEN_KIND.keys())[
                           list(TOKEN_KIND.values()).index(expected_token)
                    ] for expected_token in expected_tokens])
                } but found \"{next_token.token}\"""")

    def parse_identifier(self) -> TIdentifier:
        """ <identifier> ::= ? An identifier token ? """
        self.expect_next(self.next(), TOKEN_KIND.identifier)
        return TIdentifier(self.next_token.token)

    def parse_int(self) -> TInt:
        """ <int> ::= ? A constant token ? """
        return TInt(int(self.next_token.token))

    def parse_binary_op(self) -> CBinaryOp:
        """ <binop> ::= "-" | "+" | "*" | "/" | "%" """
        self.expect_next(self.next(), TOKEN_KIND.unop_negation,
                         TOKEN_KIND.binop_addition,
                         TOKEN_KIND.binop_multiplication,
                         TOKEN_KIND.binop_division,
                         TOKEN_KIND.binop_remainder)
        if self.next_token.token_kind == TOKEN_KIND.unop_negation:
            return CSubtract()
        if self.next_token.token_kind == TOKEN_KIND.binop_addition:
            return CAdd()
        if self.next_token.token_kind == TOKEN_KIND.binop_multiplication:
            return CMultiply()
        if self.next_token.token_kind == TOKEN_KIND.binop_division:
            return CDivide()
        if self.next_token.token_kind == TOKEN_KIND.binop_remainder:
            return CRemainder()

    def parse_unary_op(self) -> CUnaryOp:
        """ <unop> ::= "-" | "~" """
        self.expect_next(self.next(), TOKEN_KIND.unop_complement,
                         TOKEN_KIND.unop_negation)
        if self.next_token.token_kind == TOKEN_KIND.unop_complement:
            return CComplement()
        if self.next_token.token_kind == TOKEN_KIND.unop_negation:
            return CNegate()

    def parse_exp(self) -> CExp:
        """ <exp> ::= <constant> | <unop> <exp> | "(" <exp> ")" """
        self.expect_next(self.peek(), TOKEN_KIND.constant,
                         TOKEN_KIND.unop_complement,
                         TOKEN_KIND.unop_negation,
                         TOKEN_KIND.parenthesis_open)
        if self.peek_token.token_kind in (TOKEN_KIND.unop_complement,
                                          TOKEN_KIND.unop_negation):
            unary_op: CUnaryOp = self.parse_unary_op()
            inner_exp: CExp = self.parse_exp()
            return CUnary(unary_op, inner_exp)
        if self.next().token_kind == TOKEN_KIND.constant:
            value: TInt = self.parse_int()
            return CConstant(value)
        if self.next_token.token_kind == TOKEN_KIND.parenthesis_open:
            inner_exp: CExp = self.parse_exp()
            self.expect_next(self.next(), TOKEN_KIND.parenthesis_close)
            return inner_exp

    def parse_statement(self) -> CStatement:
        """ <statement> ::= "return" <exp> ";" """
        self.expect_next(self.next(), TOKEN_KIND.key_return)
        return_exp: CExp = self.parse_exp()
        self.expect_next(self.next(), TOKEN_KIND.semicolon)
        return CReturn(return_exp)

    def parse_function_def(self) -> CFunctionDef:
        """ <function> ::= "int" <identifier> "(" "void" ")" "{" <statement> "}" """
        self.expect_next(self.next(), TOKEN_KIND.key_int)
        name: TIdentifier = self.parse_identifier()
        self.expect_next(self.next(), TOKEN_KIND.parenthesis_open)
        self.expect_next(self.next(), TOKEN_KIND.key_void)
        self.expect_next(self.next(), TOKEN_KIND.parenthesis_close)
        self.expect_next(self.next(), TOKEN_KIND.brace_open)
        body: CStatement = self.parse_statement()
        self.expect_next(self.next(), TOKEN_KIND.brace_close)
        return CFunction(name, body)

    def parse_program(self) -> None:
        """ <program> ::= <function> """
        function_def: CFunctionDef = self.parse_function_def()
        self.c_ast = CProgram(function_def)


def parsing(tokens: List[Token]) -> AST:

    parser = Parser(tokens)
    while True:
        try:
            parser.parse_program()

        except StopIteration:
            break

    if parser.tokens:
        raise ParserError(
            "An error occurred in parsing, not all tokens were consumed")

    if not parser.c_ast:
        raise ParserError(
            "An error occurred in parsing, AST was not parsed")

    return parser.c_ast
