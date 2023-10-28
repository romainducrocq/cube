from pycc.util.__ast import *
from pycc.parser.c_ast import *
from pycc.intermediate.tac_ast import *

__all__ = [
    'three_address_code_generator'
]


class ThreeAddressCodeGeneratorError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(ThreeAddressCodeGeneratorError, self).__init__(message)


def three_address_code_generator(c_ast: AST) -> AST:
    # TODO
    return AST()
