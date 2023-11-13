import re
from typing import Dict, List

from ccc.util.iota_enum import IotaEnum

__all__ = [
    'TOKEN_KIND',
    'Token',
    'lexing'
]


class LexerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(LexerError, self).__init__(message)


class Token:
    token: str
    token_kind: int

    def __init__(self, token: str, token_kind: int):
        self.token = token
        self.token_kind = token_kind


TOKEN_KIND: IotaEnum = IotaEnum(
    "assignment_bitshiftleft",
    "assignment_bitshiftright",

    "unop_decrement",
    "binop_bitshiftleft",
    "binop_bitshiftright",
    "binop_and",
    "binop_or",
    "binop_equalto",
    "binop_notequal",
    "binop_lessthanorequal",
    "binop_greaterthanorequal",
    "assignment_plus",
    "assignment_difference",
    "assignment_product",
    "assignment_quotient",
    "assignment_remainder",
    "assignment_bitand",
    "assignment_bitor",
    "assignment_bitxor",

    "parenthesis_open",
    "parenthesis_close",
    "brace_open",
    "brace_close",
    "semicolon",
    "unop_complement",
    "unop_negation",
    "unop_not",
    "binop_addition",
    "binop_multiplication",
    "binop_division",
    "binop_remainder",
    "binop_bitand",
    "binop_bitor",
    "binop_bitxor",
    "binop_lessthan",
    "binop_greaterthan",
    "assignment_simple",

    "key_int",
    "key_void",
    "key_return",
    "identifier",
    "constant",

    "skip",
    "error"
)


TOKEN_REGEX: Dict[int, str] = {
    TOKEN_KIND.assignment_bitshiftleft: r"<<=",
    TOKEN_KIND.assignment_bitshiftright: r">>=",

    TOKEN_KIND.unop_decrement: r"--",
    TOKEN_KIND.binop_bitshiftleft: r"<<",
    TOKEN_KIND.binop_bitshiftright: r">>",
    TOKEN_KIND.binop_and: r"&&",
    TOKEN_KIND.binop_or: r"\|\|",
    TOKEN_KIND.binop_equalto: r"==",
    TOKEN_KIND.binop_notequal: r"!=",
    TOKEN_KIND.binop_lessthanorequal: r"<=",
    TOKEN_KIND.binop_greaterthanorequal: r">=",
    TOKEN_KIND.assignment_plus: r"\+=",
    TOKEN_KIND.assignment_difference: r"-=",
    TOKEN_KIND.assignment_product: r"\*=",
    TOKEN_KIND.assignment_quotient: r"/=",
    TOKEN_KIND.assignment_remainder: r"%=",
    TOKEN_KIND.assignment_bitand: r"&=",
    TOKEN_KIND.assignment_bitor: r"\|=",
    TOKEN_KIND.assignment_bitxor: r"\^=",

    TOKEN_KIND.parenthesis_open: r"\(",
    TOKEN_KIND.parenthesis_close: r"\)",
    TOKEN_KIND.brace_open: r"{",
    TOKEN_KIND.brace_close: r"}",
    TOKEN_KIND.semicolon: r";",
    TOKEN_KIND.unop_complement: r"~",
    TOKEN_KIND.unop_negation: r"-",
    TOKEN_KIND.unop_not: r"!",
    TOKEN_KIND.binop_addition: r"\+",
    TOKEN_KIND.binop_multiplication: r"\*",
    TOKEN_KIND.binop_division: r"/",
    TOKEN_KIND.binop_remainder: r"%",
    TOKEN_KIND.binop_bitand: r"&",
    TOKEN_KIND.binop_bitor: r"\|",
    TOKEN_KIND.binop_bitxor: r"\^",
    TOKEN_KIND.binop_lessthan: r"<",
    TOKEN_KIND.binop_greaterthan: r">",
    TOKEN_KIND.assignment_simple: r"=",

    TOKEN_KIND.key_int: r"int\b",
    TOKEN_KIND.key_void: r"void\b",
    TOKEN_KIND.key_return: r"return\b",
    TOKEN_KIND.identifier: r"[a-zA-Z_]\w*\b",
    TOKEN_KIND.constant: r"[0-9]+\b",

    TOKEN_KIND.skip: r"[ \n\r\t\f\v]",
    TOKEN_KIND.error: r"."
}


TOKEN_PATTERN: re.Pattern = re.compile(
    "|".join(f"(?P<{str(tk)}>{TOKEN_REGEX[TOKEN_KIND[tk]]})" for tk in TOKEN_KIND)
)


def lexing(filename: str) -> List[Token]:

    tokens: List[Token] = []

    with open(filename, "r", encoding="utf-8") as input_file:
        for line in input_file:

            for match in re.finditer(TOKEN_PATTERN, line):
                if match.lastgroup is None:
                    raise LexerError(
                        f"No token found in line:\n    {line}")

                if TOKEN_KIND[match.lastgroup] == TOKEN_KIND.error:
                    raise LexerError(
                        f"Invalid token \"{match.group()}\" found in line:\n    {line}")

                if TOKEN_KIND[match.lastgroup] == TOKEN_KIND.skip:
                    continue

                tokens.append(Token(token=match.group(), token_kind=TOKEN_KIND[match.lastgroup]))

    return tokens
