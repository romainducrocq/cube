from typing import List, Optional

from ccc.util.__ast import *
from ccc.parser.c_ast import *
from ccc.parser.lexer import TOKEN_KIND, Token
from ccc.parser.precedence import parse_token_precedence

__all__ = [
    'parsing'
]


class ParserError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(ParserError, self).__init__(message)


tokens: List[Token] = []
next_token: Token = Token('', TOKEN_KIND.error)
peek_token: Token = Token('', TOKEN_KIND.error)


def expect_next(_next_token: Token, *expected_tokens: int) -> None:
    if _next_token.token_kind not in expected_tokens:
        raise ParserError(
            f"""Expected token in kinds { tuple([
                list(TOKEN_KIND.keys())[
                       list(TOKEN_KIND.values()).index(expected_token)
                ] for expected_token in expected_tokens])
            } but found \"{_next_token.token}\"""")


def pop_next() -> Token:
    global next_token

    try:
        next_token = tokens.pop(0)
        return next_token
    except IndexError:
        raise StopIteration


def peek_next() -> Token:
    global peek_token

    try:
        peek_token = tokens[0]
        return peek_token
    except IndexError:
        raise StopIteration


def parse_identifier() -> TIdentifier:
    """ <identifier> ::= ? An identifier token ? """
    expect_next(pop_next(), TOKEN_KIND.identifier)
    return TIdentifier(next_token.token)


def parse_int() -> TInt:
    """ <int> ::= ? A constant token ? """
    expect_next(pop_next(), TOKEN_KIND.constant)
    return TInt(int(next_token.token))


def parse_binary_op() -> CBinaryOp:
    """ <binop> ::= "-" | "+" | "*" | "/" | "%" | "&" | "|" | "^" | "<<" | ">>" | "&&" | "||" | "==" | "!="
                  | "<" | "<=" | ">" | ">=" """
    expect_next(pop_next(), TOKEN_KIND.unop_negation,
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
    if next_token.token_kind in (TOKEN_KIND.unop_negation,
                                 TOKEN_KIND.assignment_difference):
        return CSubtract()
    if next_token.token_kind in (TOKEN_KIND.binop_addition,
                                 TOKEN_KIND.assignment_plus):
        return CAdd()
    if next_token.token_kind in (TOKEN_KIND.binop_multiplication,
                                 TOKEN_KIND.assignment_product):
        return CMultiply()
    if next_token.token_kind in (TOKEN_KIND.binop_division,
                                 TOKEN_KIND.assignment_quotient):
        return CDivide()
    if next_token.token_kind in (TOKEN_KIND.binop_remainder,
                                 TOKEN_KIND.assignment_remainder):
        return CRemainder()
    if next_token.token_kind in (TOKEN_KIND.binop_bitand,
                                 TOKEN_KIND.assignment_bitand):
        return CBitAnd()
    if next_token.token_kind in (TOKEN_KIND.binop_bitor,
                                 TOKEN_KIND.assignment_bitor):
        return CBitOr()
    if next_token.token_kind in (TOKEN_KIND.binop_bitxor,
                                 TOKEN_KIND.assignment_bitxor):
        return CBitXor()
    if next_token.token_kind in (TOKEN_KIND.binop_bitshiftleft,
                                 TOKEN_KIND.assignment_bitshiftleft):
        return CBitShiftLeft()
    if next_token.token_kind in (TOKEN_KIND.binop_bitshiftright,
                                 TOKEN_KIND.assignment_bitshiftright):
        return CBitShiftRight()
    if next_token.token_kind == TOKEN_KIND.binop_and:
        return CAnd()
    if next_token.token_kind == TOKEN_KIND.binop_or:
        return COr()
    if next_token.token_kind == TOKEN_KIND.binop_equalto:
        return CEqual()
    if next_token.token_kind == TOKEN_KIND.binop_notequal:
        return CNotEqual()
    if next_token.token_kind == TOKEN_KIND.binop_lessthan:
        return CLessThan()
    if next_token.token_kind == TOKEN_KIND.binop_lessthanorequal:
        return CLessOrEqual()
    if next_token.token_kind == TOKEN_KIND.binop_greaterthan:
        return CGreaterThan()
    if next_token.token_kind == TOKEN_KIND.binop_greaterthanorequal:
        return CGreaterOrEqual()


def parse_unary_op() -> CUnaryOp:
    """ <unop> ::= "-" | "~" | "!" """
    expect_next(pop_next(), TOKEN_KIND.unop_complement,
                TOKEN_KIND.unop_negation,
                TOKEN_KIND.unop_not)
    if next_token.token_kind == TOKEN_KIND.unop_complement:
        return CComplement()
    if next_token.token_kind == TOKEN_KIND.unop_negation:
        return CNegate()
    if next_token.token_kind == TOKEN_KIND.unop_not:
        return CNot()


def parse_factor() -> CExp:
    """ <factor> ::= <int> | <identifier> | <unop> <factor> | "(" <exp> ")" """
    expect_next(peek_next(), TOKEN_KIND.constant,
                TOKEN_KIND.identifier,
                TOKEN_KIND.unop_complement,
                TOKEN_KIND.unop_negation,
                TOKEN_KIND.unop_not,
                TOKEN_KIND.parenthesis_open)
    if peek_token.token_kind in (TOKEN_KIND.unop_complement,
                                 TOKEN_KIND.unop_negation,
                                 TOKEN_KIND.unop_not):
        unary_op: CUnaryOp = parse_unary_op()
        inner_exp: CExp = parse_factor()
        return CUnary(unary_op, inner_exp)
    if peek_token.token_kind == TOKEN_KIND.constant:
        value: TInt = parse_int()
        return CConstant(value)
    if peek_token.token_kind == TOKEN_KIND.identifier:
        name: TIdentifier = parse_identifier()
        return CVar(name)
    if pop_next().token_kind == TOKEN_KIND.parenthesis_open:
        inner_exp: CExp = parse_exp()
        expect_next(pop_next(), TOKEN_KIND.parenthesis_close)
        return inner_exp


def parse_exp(min_precedence: int = 0) -> CExp:
    """ <exp> ::= <factor> | <exp> <binop> <exp> """
    exp_left: CExp = parse_factor()
    while peek_next().token_kind in (TOKEN_KIND.unop_negation,
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
        precedence: int = parse_token_precedence(peek_token.token_kind)
        if precedence < min_precedence:
            break
        if peek_token.token_kind == TOKEN_KIND.assignment_simple:
            _ = pop_next()
            exp_right: CExp = parse_exp(precedence)
            exp_left: CExp = CAssignment(exp_left, exp_right)
        elif peek_token.token_kind in (TOKEN_KIND.assignment_plus,
                                       TOKEN_KIND.assignment_difference,
                                       TOKEN_KIND.assignment_product,
                                       TOKEN_KIND.assignment_quotient,
                                       TOKEN_KIND.assignment_remainder,
                                       TOKEN_KIND.assignment_bitand,
                                       TOKEN_KIND.assignment_bitor,
                                       TOKEN_KIND.assignment_bitxor,
                                       TOKEN_KIND.assignment_bitshiftleft,
                                       TOKEN_KIND.assignment_bitshiftright):
            binary_op: CBinaryOp = parse_binary_op()
            exp_right: CExp = parse_exp(precedence)
            exp_left: CExp = CAssignmentCompound(binary_op, exp_left, exp_right)
        else:
            binary_op: CBinaryOp = parse_binary_op()
            exp_right: CExp = parse_exp(precedence + 1)
            exp_left: CExp = CBinary(binary_op, exp_left, exp_right)
    return exp_left


def parse_statement() -> CStatement:
    """ <statement> ::= "return" <exp> ";" | <exp> ";" | ";" """
    if peek_token.token_kind == TOKEN_KIND.semicolon:
        _ = pop_next()
        return CNull()
    if peek_token.token_kind == TOKEN_KIND.key_return:
        _ = pop_next()
        return_exp: CExp = parse_exp()
        expect_next(pop_next(), TOKEN_KIND.semicolon)
        return CReturn(return_exp)
    if True:
        return_exp: CExp = parse_exp()
        expect_next(pop_next(), TOKEN_KIND.semicolon)
        return CExpression(return_exp)


def parse_declaration() -> CDeclaration:
    """ <declaration> ::= "int" <identifier> [ "=" <exp> ] ";" """
    expect_next(pop_next(), TOKEN_KIND.key_int)
    name: TIdentifier = parse_identifier()
    if peek_next().token_kind == TOKEN_KIND.assignment_simple:
        _ = pop_next()
        init: Optional[CExp] = parse_exp()
    else:
        init: Optional[CExp] = None
    expect_next(pop_next(), TOKEN_KIND.semicolon)
    return CDecl(name, init)


def parse_block_item() -> CBlockItem:
    """ <block-item> ::= <statement> | <declaration> """
    if peek_token.token_kind == TOKEN_KIND.key_int:
        declaration: CDeclaration = parse_declaration()
        return CD(declaration)
    if True:
        statement: CStatement = parse_statement()
        return CS(statement)


def parse_function_def() -> CFunctionDef:
    """ <function> ::= "int" <identifier> "(" "void" ")" "{" { <block-item> } "}" """
    expect_next(pop_next(), TOKEN_KIND.key_int)
    name: TIdentifier = parse_identifier()
    expect_next(pop_next(), TOKEN_KIND.parenthesis_open)
    expect_next(pop_next(), TOKEN_KIND.key_void)
    expect_next(pop_next(), TOKEN_KIND.parenthesis_close)
    expect_next(pop_next(), TOKEN_KIND.brace_open)
    body: List[CBlockItem] = []
    while peek_next().token_kind != TOKEN_KIND.brace_close:
        block_item: CBlockItem = parse_block_item()
        body.append(block_item)
    expect_next(pop_next(), TOKEN_KIND.brace_close)
    return CFunction(name, body)


def parse_program() -> CProgram:
    """ <program> ::= <function> """
    function_def: CFunctionDef = parse_function_def()
    return CProgram(function_def)


def parsing(lex_tokens: List[Token]) -> AST:
    global tokens
    global next_token
    global peek_token

    tokens = lex_tokens
    c_ast: AST = AST()
    while True:
        try:
            next_token: Token = Token('', TOKEN_KIND.error)
            peek_token: Token = Token('', TOKEN_KIND.error)
            c_ast = parse_program()

        except StopIteration:
            break

    if tokens:
        raise ParserError(
            "An error occurred in parsing, not all tokens were consumed")

    if not c_ast:
        raise ParserError(
            "An error occurred in parsing, AST was not parsed")

    return c_ast
