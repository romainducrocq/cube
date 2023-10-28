import re
from typing import Dict, Generator
from dataclasses import dataclass

from pycc.util.iota_enum import IotaEnum

__all__ = [
    'TOKEN_KIND',
    'Token',
    'lexing'
]


class LexerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(LexerError, self).__init__(message)


TOKEN_KIND: IotaEnum = IotaEnum(
    "key_int",
    "key_void",
    "key_return",
    "parenthesis_open",
    "parenthesis_close",
    "brace_open",
    "brace_close",
    "semicolon",
    "identifier",
    "unop_complement",
    "unop_negation",
    "unop_decrement",
    "constant",
    "skip",
    "error"
)

TOKEN_REGEX: Dict[int, str] = {
    TOKEN_KIND.key_int: r"int\b",
    TOKEN_KIND.key_void: r"void\b",
    TOKEN_KIND.key_return: r"return\b",
    TOKEN_KIND.parenthesis_open: r"\(",
    TOKEN_KIND.parenthesis_close: r"\)",
    TOKEN_KIND.brace_open: r"{",
    TOKEN_KIND.brace_close: r"}",
    TOKEN_KIND.semicolon: r";",
    TOKEN_KIND.unop_complement: r"~",
    TOKEN_KIND.unop_negation: r"-",
    TOKEN_KIND.unop_decrement: r"--",
    TOKEN_KIND.identifier: r"[a-zA-Z_]\w*\b",
    TOKEN_KIND.constant: r"[0-9]+\b",
    TOKEN_KIND.skip: r"[ \n\r\t\f\v]",
    TOKEN_KIND.error: r"."
}


@dataclass
class Token:
    token: str
    token_kind: int


TOKEN_PATTERN: re.Pattern = re.compile(
    "|".join(f"(?P<{str(tk)}>{TOKEN_REGEX[TOKEN_KIND[tk]]})" for tk in TOKEN_KIND)
)


def lexing(filename: str) -> Generator[Token, None, None]:

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

                yield Token(token=match.group(), token_kind=TOKEN_KIND[match.lastgroup])
