from re import compile as re_compile
from re import finditer as re_finditer

from ccc.util_fopen cimport file_open_read, read_line, file_close_read
from ccc.util_iota_enum cimport IotaEnum


cdef class Token:

    def __init__(self, str token, int token_kind):
        self.token = token
        self.token_kind = token_kind


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
    "ternary_if",
    "ternary_else",

    "key_int",
    "key_void",
    "key_return",
    "key_if",
    "key_else",
    "key_goto",
    "key_do",
    "key_while",
    "key_for",
    "key_break",
    "key_continue",

    "identifier",
    "constant",

    "skip",
    "error"
))


cdef dict[int, str] TOKEN_REGEX = {
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
    TOKEN_KIND.get('ternary_if'): r"\?",
    TOKEN_KIND.get('ternary_else'): r":",

    TOKEN_KIND.get('key_int'): r"int\b",
    TOKEN_KIND.get('key_void'): r"void\b",
    TOKEN_KIND.get('key_return'): r"return\b",
    TOKEN_KIND.get('key_if'): r"if\b",
    TOKEN_KIND.get('key_else'): r"else\b",
    TOKEN_KIND.get('key_goto'): r"goto\b",
    TOKEN_KIND.get('key_do'): r"do\b",
    TOKEN_KIND.get('key_while'): r"while\b",
    TOKEN_KIND.get('key_for'): r"for\b",
    TOKEN_KIND.get('key_break'): r"break\b",
    TOKEN_KIND.get('key_continue'): r"continue\b",

    TOKEN_KIND.get('identifier'): r"[a-zA-Z_]\w*\b",
    TOKEN_KIND.get('constant'): r"[0-9]+\b",

    TOKEN_KIND.get('skip'): r"[ \n\r\t\f\v]",
    TOKEN_KIND.get('error'): r"."
}


cdef object TOKEN_PATTERN = re_compile(
    "|".join(f"(?P<{str(tk)}>{TOKEN_REGEX[TOKEN_KIND.get(tk)]})" for tk in TOKEN_KIND.iter())
)


cdef list[Token] lexing(str filename):

    cdef list[Token] tokens = []

    file_open_read(filename)

    cdef bint eof
    cdef str line
    cdef object match
    while True:
        eof, line = read_line()
        if eof:
            break

        for match in re_finditer(TOKEN_PATTERN, line):
            if match.lastgroup is None:
                raise RuntimeError(
                    f"No token found in line: {line}")

            if TOKEN_KIND.get(match.lastgroup) == TOKEN_KIND.get('error'):
                raise RuntimeError(
                    f"Invalid token \"{match.group()}\" found in line: {line}")

            if TOKEN_KIND.get(match.lastgroup) == TOKEN_KIND.get('skip'):
                continue

            tokens.append(Token(token=match.group(), token_kind=TOKEN_KIND.get(match.lastgroup)))

    file_close_read()

    return tokens
