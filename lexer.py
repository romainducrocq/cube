import re

from typing import Tuple, List

from helper import debug
from tokens import TOKEN_KIND, TOKEN_REGEX


def left_split(string: str) -> str:
    char_counter: int = 0
    for char in string:
        if char in [" ", "\n", "\t", "\r"]:
            char_counter += 1
        else:
            break
    return string[char_counter:]


def next_token(string: str) -> Tuple[int, str]:
    token: str = ""
    token_kind: int = -1
    substring: str = string
    for tk in TOKEN_KIND:
        expr: str = TOKEN_REGEX[TOKEN_KIND[tk]]
        match = re.search(f"^{expr}", string)

        if match and len(match.group(0)) >= len(token):
            token = match.group(0)
            token_kind = TOKEN_KIND[tk]
            substring = re.split(f"^{expr}", string)[1]

    assert token and \
           token_kind >= 0 and \
           len(substring) < len(string), "No next token was found..."

    return token_kind, substring


def lexing(input_file: str) -> List[int]:
    f = open(input_file, "r")
    src: str = f.read()
    f.close()

    token_kinds: List[int] = []

    while src:
        src = left_split(src)
        if not src:
            break

        token_kinds.append(-1)
        token_kinds[-1], src = next_token(src)

    debug(f"Token kinds: {token_kinds}") # TODO rm

    return token_kinds
