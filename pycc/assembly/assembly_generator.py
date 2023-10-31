from typing import List
from copy import deepcopy

from pycc.util.__ast import *
from pycc.intermediate.tac_ast import *
from pycc.assembly.asm_ast import *
from pycc.assembly.stack import StackManager

__all__ = [
    'assembly_generation'
]


class AssemblyGeneratorError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(AssemblyGeneratorError, self).__init__(message)


# TODO add back ADSL comments
class AssemblyGenerator:
    asm_ast: AST = None
    stack_mngr: StackManager = StackManager()

    def __init__(self):
        pass

    def generate_stack(self) -> None:
        self.stack_mngr.generate_stack(self.asm_ast)

    @staticmethod
    def expect_next(next_node, *expected_nodes: type) -> None:
        if not isinstance(next_node, expected_nodes):
            raise AssemblyGeneratorError(
                f"Expected node in types {expected_nodes} but found \"{type(next_node)}\"")

    def generate_identifier(self, node: AST) -> TIdentifier:
        self.expect_next(node, TIdentifier)
        return TIdentifier(deepcopy(node.str_t))

    def generate_int(self, node: AST) -> TInt:
        self.expect_next(node, TInt)
        return TInt(deepcopy(node.int_t))

    @staticmethod
    def generate_register(register: str) -> AsmReg:
        if register == "ax":
            return AsmAx()

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_operand(self, node: AST = None) -> AsmOperand:
        self.expect_next(node, TacValue,
                         type(None))
        if isinstance(node, TacConstant):
            value: TInt = self.generate_int(node.value)
            return AsmImm(value)
        if isinstance(node, TacVariable):
            identifier: TIdentifier = self.generate_identifier(node.name)
            return AsmPseudo(identifier)
        if isinstance(node, type(None)):
            register: AsmReg = self.generate_register("ax")
            return AsmRegister(register)

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_unary_op(self, node: AST) -> AsmUnaryOp:
        self.expect_next(node, TacUnaryOp)
        if isinstance(node, TacComplement):
            return AsmNot()
        if isinstance(node, TacNegate):
            return AsmNeg()

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_instructions(self, list_node: list) -> List[AsmInstruction]:
        self.expect_next(list_node, list)

        instructions: List[AsmInstruction] = []

        def generate_instruction(node: AST) -> None:
            self.expect_next(node, TacInstruction)
            if isinstance(node, TacReturn):
                src: AsmOperand = self.generate_operand(node.val)
                dst: AsmOperand = self.generate_operand()
                instructions.append(AsmMov(src, dst))
                instructions.append(AsmRet())
            elif isinstance(node, TacUnary):
                unary_op: AsmUnaryOp = self.generate_unary_op(node.unary_op)
                src: AsmOperand = self.generate_operand(node.src)
                dst: AsmOperand = self.generate_operand(node.dst)
                instructions.append(AsmMov(src, dst))
                instructions.append(AsmUnary(unary_op, deepcopy(dst)))
            else:

                raise AssemblyGeneratorError(
                    "An error occurred in assembly generation, not all nodes were visited")

        for item_node in list_node:
            generate_instruction(item_node)

        return instructions

    def generate_function_def(self, node: AST) -> AsmFunctionDef:
        self.expect_next(node, TacFunctionDef)
        if isinstance(node, TacFunction):
            name: TIdentifier = self.generate_identifier(node.name)
            instructions: List[AsmInstruction] = self.generate_instructions(node.body)
            return AsmFunction(name, instructions)

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_program(self, node: AST) -> None:
        self.expect_next(node, AST)
        if isinstance(node, TacProgram):
            function_def: AsmFunctionDef = self.generate_function_def(node.function_def)
            self.asm_ast = AsmProgram(function_def)
        else:

            raise AssemblyGeneratorError(
                "An error occurred in assembly generation, not all nodes were visited")


def assembly_generation(tac_ast: AST) -> AST:

    assembly_generator = AssemblyGenerator()

    assembly_generator.generate_program(tac_ast)

    if not assembly_generator.asm_ast:
        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, ASM was not generated")

    assembly_generator.generate_stack()

    return assembly_generator.asm_ast
