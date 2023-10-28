from typing import List

from pycc.util.__ast import *
from pycc.parser.c_ast import *
from pycc.assembly.asm_ast import *

__all__ = [
    'assembly_generation'
]


class AssemblyGeneratorError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(AssemblyGeneratorError, self).__init__(message)


class AssemblyGenerator:
    asm_ast: AST = None

    def __init__(self):
        pass

    @staticmethod
    def expect_next(next_node, *expected_nodes: type) -> None:
        if not isinstance(next_node, expected_nodes):
            raise AssemblyGeneratorError(
                f"Expected node in types {expected_nodes} but found \"{type(next_node)}\"")

    def generate_identifier(self, node: AST) -> TIdentifier:
        """ <identifier> = Built-in identifier type """
        self.expect_next(node, TIdentifier)
        return TIdentifier(node.str_t)

    def generate_int(self, node: AST) -> TInt:
        """ <int> = Built-in int type """
        self.expect_next(node, TInt)
        return TInt(node.int_t)

    def generate_operand(self, node: AST = None) -> AsmOperand:
        """ operand = Imm(int value) | Register """
        self.expect_next(node, CConstant, type(None))
        if isinstance(node, CConstant):
            value: TInt = self.generate_int(node.value)
            return AsmImm(value)
        if isinstance(node, type(None)):
            return AsmRegister()

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_instructions(self, node: AST) -> List[AsmInstruction]:
        """ instruction = Mov(operand src, operand dst) | Ret """
        self.expect_next(node, CStatement)
        if isinstance(node, CReturn):
            src: AsmOperand = self.generate_operand(node.exp)
            dst: AsmOperand = self.generate_operand()
            return [AsmMov(src, dst), AsmRet()]

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_function_def(self, node: AST) -> AsmFunctionDef:
        """ function_definition = Function(identifier name, instruction* instructions) """
        self.expect_next(node, CFunctionDef)
        if isinstance(node, CFunction):
            name: TIdentifier = self.generate_identifier(node.name)
            instructions: List[AsmInstruction] = self.generate_instructions(node.body)
            return AsmFunction(name, instructions)

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_program(self, node: AST) -> None:
        """ program = Program(function_definition) """
        self.expect_next(node, AST)
        if isinstance(node, CProgram):
            function_def: AsmFunctionDef = self.generate_function_def(node.function_def)
            self.asm_ast = AsmProgram(function_def)
        else:

            raise AssemblyGeneratorError(
                "An error occurred in assembly generation, not all nodes were visited")


def assembly_generation(c_ast: AST) -> AST:

    assembly_generator = AssemblyGenerator()

    assembly_generator.generate_program(c_ast)

    if not assembly_generator.asm_ast:
        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, ASM was not generated")

    return assembly_generator.asm_ast
