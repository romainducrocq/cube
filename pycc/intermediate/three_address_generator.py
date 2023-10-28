from pycc.util.__ast import *
from pycc.parser.c_ast import *
from pycc.intermediate.tac_ast import *

__all__ = [
    'three_address_code_representation'
]


class ThreeAddressCodeGeneratorError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(ThreeAddressCodeGeneratorError, self).__init__(message)


class ThreeAddressCodeGenerator:
    tac_ast: AST = None

    def __init__(self):
        pass

    @staticmethod
    def expect_next(next_node, *expected_nodes: type) -> None:
        if not isinstance(next_node, expected_nodes):
            raise ThreeAddressCodeGeneratorError(
                f"Expected node in types {expected_nodes} but found \"{type(next_node)}\"")

    def represente_program(self, node: AST) -> None:
        # TODO
        self.tac_ast = AST()


def three_address_code_representation(c_ast: AST) -> AST:

    three_address_code_generator = ThreeAddressCodeGenerator()

    three_address_code_generator.represente_program(c_ast)

    if not three_address_code_generator.tac_ast:
        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, ASM was not generated")

    return three_address_code_generator.tac_ast
