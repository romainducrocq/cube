import re

from ccc.util_iota_enum cimport IotaEnum


__all__ = [
    'TOKEN_KIND',
    'Token',
    'lexing'
]


class LexerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(LexerError, self).__init__(message)


cdef class Token:
    cdef str token
    cdef int token_kind

    def __init__(self, token: str, token_kind: int):
        self.token = token
        self.token_kind = token_kind

cdef IotaEnum TOKEN_KIND
TOKEN_KIND = IotaEnum((
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
))


cdef dict[int, str] TOKEN_REGEX
TOKEN_REGEX = {
    TOKEN_KIND.get('assignment_bitshiftleft'): r"<<=",
    TOKEN_KIND.get('assignment_bitshiftright'): r">>=",

    TOKEN_KIND.get('unop_decrement'): r"--",
    TOKEN_KIND.get('binop_bitshiftleft'): r"<<",
    TOKEN_KIND.get('binop_bitshiftright'): r">>",
    TOKEN_KIND.get('binop_and'): r"&&",
    TOKEN_KIND.get('binop_or'): r"\|\|",
    TOKEN_KIND.get('binop_equalto'): r"==",
    TOKEN_KIND.get('binop_notequal'): r"!=",
    TOKEN_KIND.get('binop_lessthanorequal'): r"<=",
    TOKEN_KIND.get('binop_greaterthanorequal'): r">=",
    TOKEN_KIND.get('assignment_plus'): r"\+=",
    TOKEN_KIND.get('assignment_difference'): r"-=",
    TOKEN_KIND.get('assignment_product'): r"\*=",
    TOKEN_KIND.get('assignment_quotient'): r"/=",
    TOKEN_KIND.get('assignment_remainder'): r"%=",
    TOKEN_KIND.get('assignment_bitand'): r"&=",
    TOKEN_KIND.get('assignment_bitor'): r"\|=",
    TOKEN_KIND.get('assignment_bitxor'): r"\^=",

    TOKEN_KIND.get('parenthesis_open'): r"\(",
    TOKEN_KIND.get('parenthesis_close'): r"\)",
    TOKEN_KIND.get('brace_open'): r"{",
    TOKEN_KIND.get('brace_close'): r"}",
    TOKEN_KIND.get('semicolon'): r";",
    TOKEN_KIND.get('unop_complement'): r"~",
    TOKEN_KIND.get('unop_negation'): r"-",
    TOKEN_KIND.get('unop_not'): r"!",
    TOKEN_KIND.get('binop_addition'): r"\+",
    TOKEN_KIND.get('binop_multiplication'): r"\*",
    TOKEN_KIND.get('binop_division'): r"/",
    TOKEN_KIND.get('binop_remainder'): r"%",
    TOKEN_KIND.get('binop_bitand'): r"&",
    TOKEN_KIND.get('binop_bitor'): r"\|",
    TOKEN_KIND.get('binop_bitxor'): r"\^",
    TOKEN_KIND.get('binop_lessthan'): r"<",
    TOKEN_KIND.get('binop_greaterthan'): r">",
    TOKEN_KIND.get('assignment_simple'): r"=",

    TOKEN_KIND.get('key_int'): r"int\b",
    TOKEN_KIND.get('key_void'): r"void\b",
    TOKEN_KIND.get('key_return'): r"return\b",
    TOKEN_KIND.get('identifier'): r"[a-zA-Z_]\w*\b",
    TOKEN_KIND.get('constant'): r"[0-9]+\b",

    TOKEN_KIND.get('skip'): r"[ \n\r\t\f\v]",
    TOKEN_KIND.get('error'): r"."
}


# TOKEN_PATTERN: re.Pattern = re.compile(
cdef object TOKEN_PATTERN
TOKEN_PATTERN = re.compile(
    "|".join(f"(?P<{str(tk)}>{TOKEN_REGEX[TOKEN_KIND[tk]]})" for tk in TOKEN_KIND)
)


cpdef list[Token] lexing(str filename):
    cdef str line
    cdef list[Token] tokens
    cdef object input_file, match

    tokens = []
    with open(filename, "r", encoding="utf-8") as input_file:
        for line in input_file:

            for match in re.finditer(TOKEN_PATTERN, line):
                if match.lastgroup is None:
                    raise LexerError(
                        f"No token found in line:\n    {line}")

                if TOKEN_KIND.get(match.lastgroup) == TOKEN_KIND.get('error'):
                    raise LexerError(
                        f"Invalid token \"{match.group()}\" found in line:\n    {line}")

                if TOKEN_KIND.get(match.lastgroup) == TOKEN_KIND.get('skip'):
                    continue

                tokens.append(Token(token=match.group(), token_kind=TOKEN_KIND.get(match.lastgroup)))

    return tokens
