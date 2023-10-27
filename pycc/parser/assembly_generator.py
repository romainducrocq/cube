from pycc.parser.__ast import *
from pycc.parser.__asm import *

__all__ = [
    'assembly_generation'
]


class AssemblyGeneratorError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(AssemblyGeneratorError, self).__init__(message)


class AssemblyGenerator:
    asm_ast: AST = None

    def __init__(self, c_ast: AST):
        self.c_ast: AST = c_ast


def assembly_generation(ast_c: AST) -> AST:

    assembly_generator = AssemblyGenerator(ast_c)

    if not assembly_generator.asm_ast:
        raise AssemblyGeneratorError(
            "An error occurred in parsing, assembly AST was not parsed")

    return assembly_generator.asm_ast
