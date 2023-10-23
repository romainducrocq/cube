from typing import Generator

from lexer import Token


def parse_statement(tokens: Generator[Token, None, None]) -> None:
    first_token = next(tokens)

    print(first_token)


def parsing(tokens: Generator[Token, None, None]) -> None:
    while True:
        try:
            parse_statement(tokens)

        except StopIteration:
            break  # end of file

    pass
