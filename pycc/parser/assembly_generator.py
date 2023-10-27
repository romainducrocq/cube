from typing import List, Generator

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

    def __init__(self):
        pass

    def expect_next(self, next_node, *expected_nodes: int) -> None:
        if not isinstance(next_node, *expected_nodes):
            raise AssemblyGeneratorError(
                f"Expected node of types ({str(*expected_nodes)}) but found {type(next_node)}\"")

    def parse_operand(self, node: AST = None) -> AsmOperand:
        """ operand = Imm(int value) | Register """
        if node:
            self.expect_next(node, CConstant)
            return AsmImm(node.value)
        return AsmRegister()

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def parse_instructions(self, node: AST) -> List[AsmInstruction]:
        """ instruction = Mov(operand src, operand dst) | Ret """
        self.expect_next(node, CStatement)
        if isinstance(node, CReturn):
            src: AsmOperand = self.parse_operand(node.exp)
            dst: AsmOperand = self.parse_operand()
            return [AsmMov(src, dst), AsmRet()]

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def parse_function_def(self, node: AST) -> AsmFunctionDef:
        """ function_definition = Function(identifier name, instruction* instructions) """
        self.expect_next(node, CFunctionDef)
        if isinstance(node, CFunction):
            name: TIdentifier = TIdentifier(node.name)
            instructions: List[AsmInstruction] = self.parse_instructions(node.body)
            return AsmFunction(name, instructions)

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def parse_program(self, node: AST) -> None:
        """ program = Program(function_definition) """
        self.expect_next(node, AST)
        if isinstance(node, CProgram):
            function_def: AsmFunctionDef = self.parse_function_def(node.function_def)
            self.asm_ast = AsmProgram(function_def)
            return

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

def assembly_generation(c_ast: AST) -> AST:

    assembly_generator = AssemblyGenerator()

    assembly_generator.parse_program(c_ast)

    if not assembly_generator.asm_ast:
        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, AST was not parsed")

    return assembly_generator.asm_ast
