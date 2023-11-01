from typing import Dict

from pycc.parser.lexer import TOKEN_KIND

__all__ = [
    'PrecedenceManager'
]


class PrecedenceManagerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(PrecedenceManagerError, self).__init__(message)


TOKEN_PRECEDENCE: Dict[int, int] = {
    TOKEN_KIND.unop_negation: 45,
    TOKEN_KIND.binop_addition: 45,
    TOKEN_KIND.binop_multiplication: 50,
    TOKEN_KIND.binop_division: 50,
    TOKEN_KIND.binop_remainder: 50
}


class PrecedenceManager:

    def __init__(self):
        pass

    @staticmethod
    def parse_token_precedence(token_kind: int) -> int:
        try:
            precedence = TOKEN_PRECEDENCE[token_kind]
        except KeyError:

            raise PrecedenceManagerError(
                f"""An error occurred in precedence management, unmanaged token {
                    list(TOKEN_KIND.keys())[list(TOKEN_KIND.values()).index(token_kind)]}""")

        return precedence
