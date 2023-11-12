from typing import List, Optional

from pycc.util.__ast import *
from pycc.parser.c_ast import *
from pycc.parser.lexer import TOKEN_KIND, Token
from pycc.parser.precedence import PrecedenceManager

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
        self.expect_next(self.next(), TOKEN_KIND.constant)
        return TInt(int(self.next_token.token))

    def parse_binary_op(self) -> CBinaryOp:
        """ <binop> ::= "-" | "+" | "*" | "/" | "%" | "&" | "|" | "^" | "<<" | ">>" | "&&" | "||" | "==" | "!="
                      | "<" | "<=" | ">" | ">=" """
        self.expect_next(self.next(), TOKEN_KIND.unop_negation,
                         TOKEN_KIND.binop_addition,
                         TOKEN_KIND.binop_multiplication,
                         TOKEN_KIND.binop_division,
                         TOKEN_KIND.binop_remainder,
                         TOKEN_KIND.binop_bitand,
                         TOKEN_KIND.binop_bitor,
                         TOKEN_KIND.binop_bitxor,
                         TOKEN_KIND.binop_bitshiftleft,
                         TOKEN_KIND.binop_bitshiftright,
                         TOKEN_KIND.binop_lessthan,
                         TOKEN_KIND.binop_lessthanorequal,
                         TOKEN_KIND.binop_greaterthan,
                         TOKEN_KIND.binop_greaterthanorequal,
                         TOKEN_KIND.binop_equalto,
                         TOKEN_KIND.binop_notequal,
                         TOKEN_KIND.binop_and,
                         TOKEN_KIND.binop_or,
                         TOKEN_KIND.assignment_plus,
                         TOKEN_KIND.assignment_difference,
                         TOKEN_KIND.assignment_product,
                         TOKEN_KIND.assignment_quotient,
                         TOKEN_KIND.assignment_remainder,
                         TOKEN_KIND.assignment_bitand,
                         TOKEN_KIND.assignment_bitor,
                         TOKEN_KIND.assignment_bitxor,
                         TOKEN_KIND.assignment_bitshiftleft,
                         TOKEN_KIND.assignment_bitshiftright)
        if self.next_token.token_kind in (TOKEN_KIND.unop_negation,
                                          TOKEN_KIND.assignment_difference):
            return CSubtract()
        if self.next_token.token_kind in (TOKEN_KIND.binop_addition,
                                          TOKEN_KIND.assignment_plus):
            return CAdd()
        if self.next_token.token_kind in (TOKEN_KIND.binop_multiplication,
                                          TOKEN_KIND.assignment_product):
            return CMultiply()
        if self.next_token.token_kind in (TOKEN_KIND.binop_division,
                                          TOKEN_KIND.assignment_quotient):
            return CDivide()
        if self.next_token.token_kind in (TOKEN_KIND.binop_remainder,
                                          TOKEN_KIND.assignment_remainder):
            return CRemainder()
        if self.next_token.token_kind in (TOKEN_KIND.binop_bitand,
                                          TOKEN_KIND.assignment_bitand):
            return CBitAnd()
        if self.next_token.token_kind in (TOKEN_KIND.binop_bitor,
                                          TOKEN_KIND.assignment_bitor):
            return CBitOr()
        if self.next_token.token_kind in (TOKEN_KIND.binop_bitxor,
                                          TOKEN_KIND.assignment_bitxor):
            return CBitXor()
        if self.next_token.token_kind in (TOKEN_KIND.binop_bitshiftleft,
                                          TOKEN_KIND.assignment_bitshiftleft):
            return CBitShiftLeft()
        if self.next_token.token_kind in (TOKEN_KIND.binop_bitshiftright,
                                          TOKEN_KIND.assignment_bitshiftright):
            return CBitShiftRight()
        if self.next_token.token_kind == TOKEN_KIND.binop_and:
            return CAnd()
        if self.next_token.token_kind == TOKEN_KIND.binop_or:
            return COr()
        if self.next_token.token_kind == TOKEN_KIND.binop_equalto:
            return CEqual()
        if self.next_token.token_kind == TOKEN_KIND.binop_notequal:
            return CNotEqual()
        if self.next_token.token_kind == TOKEN_KIND.binop_lessthan:
            return CLessThan()
        if self.next_token.token_kind == TOKEN_KIND.binop_lessthanorequal:
            return CLessOrEqual()
        if self.next_token.token_kind == TOKEN_KIND.binop_greaterthan:
            return CGreaterThan()
        if self.next_token.token_kind == TOKEN_KIND.binop_greaterthanorequal:
            return CGreaterOrEqual()

    def parse_unary_op(self) -> CUnaryOp:
        """ <unop> ::= "-" | "~" | "!" """
        self.expect_next(self.next(), TOKEN_KIND.unop_complement,
                         TOKEN_KIND.unop_negation,
                         TOKEN_KIND.unop_not)
        if self.next_token.token_kind == TOKEN_KIND.unop_complement:
            return CComplement()
        if self.next_token.token_kind == TOKEN_KIND.unop_negation:
            return CNegate()
        if self.next_token.token_kind == TOKEN_KIND.unop_not:
            return CNot()

    def parse_factor(self) -> CExp:
        """ <factor> ::= <int> | <identifier> | <unop> <factor> | "(" <exp> ")" """
        self.expect_next(self.peek(), TOKEN_KIND.constant,
                         TOKEN_KIND.identifier,
                         TOKEN_KIND.unop_complement,
                         TOKEN_KIND.unop_negation,
                         TOKEN_KIND.unop_not,
                         TOKEN_KIND.parenthesis_open)
        if self.peek_token.token_kind in (TOKEN_KIND.unop_complement,
                                          TOKEN_KIND.unop_negation,
                                          TOKEN_KIND.unop_not):
            unary_op: CUnaryOp = self.parse_unary_op()
            inner_exp: CExp = self.parse_factor()
            return CUnary(unary_op, inner_exp)
        if self.peek_token.token_kind == TOKEN_KIND.constant:
            value: TInt = self.parse_int()
            return CConstant(value)
        if self.peek_token.token_kind == TOKEN_KIND.identifier:
            name: TIdentifier = self.parse_identifier()
            return CVar(name)
        if self.next().token_kind == TOKEN_KIND.parenthesis_open:
            inner_exp: CExp = self.parse_exp()
            self.expect_next(self.next(), TOKEN_KIND.parenthesis_close)
            return inner_exp

    def parse_exp(self, min_precedence: int = 0) -> CExp:
        """ <exp> ::= <factor> | <exp> <binop> <exp> """
        exp_left: CExp = self.parse_factor()
        while self.peek().token_kind in (TOKEN_KIND.unop_negation,
                                         TOKEN_KIND.binop_addition,
                                         TOKEN_KIND.binop_multiplication,
                                         TOKEN_KIND.binop_division,
                                         TOKEN_KIND.binop_remainder,
                                         TOKEN_KIND.binop_bitand,
                                         TOKEN_KIND.binop_bitor,
                                         TOKEN_KIND.binop_bitxor,
                                         TOKEN_KIND.binop_bitshiftleft,
                                         TOKEN_KIND.binop_bitshiftright,
                                         TOKEN_KIND.binop_lessthan,
                                         TOKEN_KIND.binop_lessthanorequal,
                                         TOKEN_KIND.binop_greaterthan,
                                         TOKEN_KIND.binop_greaterthanorequal,
                                         TOKEN_KIND.binop_equalto,
                                         TOKEN_KIND.binop_notequal,
                                         TOKEN_KIND.binop_and,
                                         TOKEN_KIND.binop_or,
                                         TOKEN_KIND.assignment_simple,
                                         TOKEN_KIND.assignment_plus,
                                         TOKEN_KIND.assignment_difference,
                                         TOKEN_KIND.assignment_product,
                                         TOKEN_KIND.assignment_quotient,
                                         TOKEN_KIND.assignment_remainder,
                                         TOKEN_KIND.assignment_bitand,
                                         TOKEN_KIND.assignment_bitor,
                                         TOKEN_KIND.assignment_bitxor,
                                         TOKEN_KIND.assignment_bitshiftleft,
                                         TOKEN_KIND.assignment_bitshiftright):
            precedence: int = PrecedenceManager.\
                               parse_token_precedence(self.peek_token.token_kind)
            if precedence < min_precedence:
                break
            if self.peek_token.token_kind == TOKEN_KIND.assignment_simple:
                _ = self.next()
                exp_right: CExp = self.parse_exp(precedence)
                exp_left: CExp = CAssignment(exp_left, exp_right)
            elif self.peek_token.token_kind in (TOKEN_KIND.assignment_plus,
                                                TOKEN_KIND.assignment_difference,
                                                TOKEN_KIND.assignment_product,
                                                TOKEN_KIND.assignment_quotient,
                                                TOKEN_KIND.assignment_remainder,
                                                TOKEN_KIND.assignment_bitand,
                                                TOKEN_KIND.assignment_bitor,
                                                TOKEN_KIND.assignment_bitxor,
                                                TOKEN_KIND.assignment_bitshiftleft,
                                                TOKEN_KIND.assignment_bitshiftright):
                binary_op: CBinaryOp = self.parse_binary_op()
                exp_right: CExp = self.parse_exp(precedence)
                exp_left: CExp = CAssignmentCompound(binary_op, exp_left, exp_right)
            else:
                binary_op: CBinaryOp = self.parse_binary_op()
                exp_right: CExp = self.parse_exp(precedence + 1)
                exp_left: CExp = CBinary(binary_op, exp_left, exp_right)
        return exp_left

    def parse_statement(self) -> CStatement:
        """ <statement> ::= "return" <exp> ";" | <exp> ";" | ";" """
        if self.peek_token.token_kind == TOKEN_KIND.semicolon:
            _ = self.next()
            return CNull()
        if self.peek_token.token_kind == TOKEN_KIND.key_return:
            _ = self.next()
            return_exp: CExp = self.parse_exp()
            self.expect_next(self.next(), TOKEN_KIND.semicolon)
            return CReturn(return_exp)
        if True:
            return_exp: CExp = self.parse_exp()
            self.expect_next(self.next(), TOKEN_KIND.semicolon)
            return CExpression(return_exp)

    def parse_declaration(self) -> CDeclaration:
        """ <declaration> ::= "int" <identifier> [ "=" <exp> ] ";" """
        self.expect_next(self.next(), TOKEN_KIND.key_int)
        name: TIdentifier = self.parse_identifier()
        if self.peek().token_kind == TOKEN_KIND.assignment_simple:
            _ = self.next()
            init: Optional[CExp] = self.parse_exp()
        else:
            init: Optional[CExp] = None
        self.expect_next(self.next(), TOKEN_KIND.semicolon)
        return CDecl(name, init)

    def parse_block_item(self) -> CBlockItem:
        """ <block-item> ::= <statement> | <declaration> """
        if self.peek_token.token_kind == TOKEN_KIND.key_int:
            declaration: CDeclaration = self.parse_declaration()
            return CD(declaration)
        if True:
            statement: CStatement = self.parse_statement()
            return CS(statement)

    def parse_function_def(self) -> CFunctionDef:
        """ <function> ::= "int" <identifier> "(" "void" ")" "{" { <block-item> } "}" """
        self.expect_next(self.next(), TOKEN_KIND.key_int)
        name: TIdentifier = self.parse_identifier()
        self.expect_next(self.next(), TOKEN_KIND.parenthesis_open)
        self.expect_next(self.next(), TOKEN_KIND.key_void)
        self.expect_next(self.next(), TOKEN_KIND.parenthesis_close)
        self.expect_next(self.next(), TOKEN_KIND.brace_open)
        body: List[CBlockItem] = []
        while self.peek().token_kind != TOKEN_KIND.brace_close:
            block_item: CBlockItem = self.parse_block_item()
            body.append(block_item)
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
