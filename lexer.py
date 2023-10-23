import re
from typing import Generator
from dataclasses import dataclass

from util import iota, AttributeDict


class LexerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__()


TOKEN_KIND: AttributeDict[str, int] = AttributeDict({
    "key_int": iota(init=True),     # int\b
    "key_void": iota(),             # void\b
    "key_return": iota(),           # return\b
    "parenthesis_open": iota(),     # \(
    "parenthesis_close": iota(),    # \)
    "brace_open": iota(),           # {
    "brace_close": iota(),          # }
    "semicolon": iota(),            # ;
    "newline": iota(),              # \n
    "identifier": iota(),           # [a-zA-Z_]\w*\b
    "constant": iota(),             # [0-9]+\b
    "skip": iota(),
    "error": iota()
})


TOKEN_REGEX: AttributeDict[int, str] = AttributeDict({
    TOKEN_KIND.identifier: r"[a-zA-Z_]\w*\b",
    TOKEN_KIND.constant: r"[0-9]+\b",
    TOKEN_KIND.key_int: r"int\b",
    TOKEN_KIND.key_void: r"void\b",
    TOKEN_KIND.key_return: r"return\b",
    TOKEN_KIND.parenthesis_open: r"\(",
    TOKEN_KIND.parenthesis_close: r"\)",
    TOKEN_KIND.brace_open: r"{",
    TOKEN_KIND.brace_close: r"}",
    TOKEN_KIND.semicolon: r";",
    TOKEN_KIND.newline: r"\n",
    TOKEN_KIND.skip: r"[ \r\t\f\v]",
    TOKEN_KIND.error: r"."
})


@dataclass
class Token:
    token: str
    token_kind: int


TOKEN_PATTERN: re.Pattern = re.compile(
    "|".join(f"(?P<{str(tk)}>{TOKEN_REGEX[TOKEN_KIND[tk]]})" for tk in TOKEN_KIND),
    flags=re.IGNORECASE
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
