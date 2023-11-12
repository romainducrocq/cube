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
    TOKEN_KIND.binop_multiplication: 50,
    TOKEN_KIND.binop_division: 50,
    TOKEN_KIND.binop_remainder: 50,
    TOKEN_KIND.unop_negation: 45,
    TOKEN_KIND.binop_addition: 45,
    TOKEN_KIND.binop_bitshiftleft: 40,
    TOKEN_KIND.binop_bitshiftright: 40,
    TOKEN_KIND.binop_lessthan: 35,
    TOKEN_KIND.binop_lessthanorequal: 35,
    TOKEN_KIND.binop_greaterthan: 35,
    TOKEN_KIND.binop_greaterthanorequal: 35,
    TOKEN_KIND.binop_equalto: 30,
    TOKEN_KIND.binop_notequal: 30,
    TOKEN_KIND.binop_bitand: 25,
    TOKEN_KIND.binop_bitxor: 20,
    TOKEN_KIND.binop_bitor: 15,
    TOKEN_KIND.binop_and: 10,
    TOKEN_KIND.binop_or: 5,
    TOKEN_KIND.assignment_simple: 1,
    TOKEN_KIND.assignment_plus: 1,
    TOKEN_KIND.assignment_difference: 1,
    TOKEN_KIND.assignment_product: 1,
    TOKEN_KIND.assignment_quotient: 1,
    TOKEN_KIND.assignment_remainder: 1,
    TOKEN_KIND.assignment_bitand: 1,
    TOKEN_KIND.assignment_bitor: 1,
    TOKEN_KIND.assignment_bitxor: 1,
    TOKEN_KIND.assignment_bitshiftleft: 1,
    TOKEN_KIND.assignment_bitshiftright: 1
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
