from typing import List, Union
from copy import deepcopy

from pycc.util.__ast import *
from pycc.intermediate.tac_ast import *
from pycc.assembly.asm_ast import *
from pycc.assembly.register import REGISTER_KIND, RegisterManager
from pycc.assembly.stack import StackManager

__all__ = [
    'assembly_generation'
]


class AssemblyGeneratorError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(AssemblyGeneratorError, self).__init__(message)


class AssemblyGenerator:
    asm_ast: AST = None
    stack_mngr: StackManager = StackManager()

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
        return TIdentifier(deepcopy(node.str_t))

    def generate_int(self, node: AST) -> TInt:
        """ <int> = Built-in int type """
        self.expect_next(node, TInt)
        return TInt(deepcopy(node.int_t))

    def generate_operand(self, node: Union[AST, int]) -> AsmOperand:
        """ operand = Imm(int) | Reg(reg) | Pseudo(identifier) | Stack(int) """
        self.expect_next(node, TacValue,
                         int)
        if isinstance(node, TacConstant):
            value: TInt = self.generate_int(node.value)
            return AsmImm(value)
        if isinstance(node, TacVariable):
            identifier: TIdentifier = self.generate_identifier(node.name)
            return AsmPseudo(identifier)
        if isinstance(node, int):
            register: AsmReg = RegisterManager.generate_register(node)
            return AsmRegister(register)

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_binary_op(self, node: AST) -> AsmBinaryOp:
        """ binary_operator = Add | Sub | Mult  """
        self.expect_next(node, TacBinaryOp)
        if isinstance(node, TacAdd):
            return AsmAdd()
        if isinstance(node, TacSubtract):
            return AsmSub()
        if isinstance(node, TacMultiply):
            return AsmMult()

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_unary_op(self, node: AST) -> AsmUnaryOp:
        """ unary_operator = Not | Neg """
        self.expect_next(node, TacUnaryOp)
        if isinstance(node, TacComplement):
            return AsmNot()
        if isinstance(node, TacNegate):
            return AsmNeg()

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_instructions(self, list_node: list) -> List[AsmInstruction]:
        """ instruction = Mov(operand src, operand dst) | Unary(unary_operator, operand) | AllocateStack(int) | Ret """
        self.expect_next(list_node, list)

        instructions: List[AsmInstruction] = []

        def generate_instruction(node: AST) -> None:
            self.expect_next(node, TacInstruction)
            if isinstance(node, TacReturn):
                src: AsmOperand = self.generate_operand(node.val)
                dst: AsmOperand = self.generate_operand(REGISTER_KIND.AX)
                instructions.append(AsmMov(src, dst))
                instructions.append(AsmRet())
            elif isinstance(node, TacUnary):
                unary_op: AsmUnaryOp = self.generate_unary_op(node.unary_op)
                src: AsmOperand = self.generate_operand(node.src)
                src_dst: AsmOperand = self.generate_operand(node.dst)
                instructions.append(AsmMov(src, src_dst))
                instructions.append(AsmUnary(unary_op, deepcopy(src_dst)))
            elif isinstance(node, TacBinary):
                if isinstance(node.binary_op, (TacDivide, TacRemainder)):
                    src1: AsmOperand = self.generate_operand(node.src1)
                    src2: AsmOperand = self.generate_operand(node.src2)
                    dst: AsmOperand = self.generate_operand(node.dst)
                    src1_dst: AsmOperand = self.generate_operand(REGISTER_KIND.AX)
                    if isinstance(node.binary_op, TacDivide):
                        dst_src: AsmOperand = self.generate_operand(REGISTER_KIND.AX)
                    else:
                        dst_src: AsmOperand = self.generate_operand(REGISTER_KIND.DX)
                    instructions.append(AsmMov(src1, src1_dst))
                    instructions.append(AsmCdq())
                    instructions.append(AsmIdiv(src2))
                    instructions.append(AsmMov(dst_src, dst))
                else:
                    binary_op: AsmBinaryOp = self.generate_binary_op(node.binary_op)
                    src1: AsmOperand = self.generate_operand(node.src1)
                    src2: AsmOperand = self.generate_operand(node.src2)
                    src1_dst: AsmOperand = self.generate_operand(node.dst)
                    instructions.append(AsmMov(src1, src1_dst))
                    instructions.append(AsmBinary(binary_op, src2, deepcopy(src1_dst)))
            else:

                raise AssemblyGeneratorError(
                    "An error occurred in assembly generation, not all nodes were visited")

        for item_node in list_node:
            generate_instruction(item_node)

        return instructions

    def generate_function_def(self, node: AST) -> AsmFunctionDef:
        """ function_definition = Function(identifier name, instruction* instructions) """
        self.expect_next(node, TacFunctionDef)
        if isinstance(node, TacFunction):
            name: TIdentifier = self.generate_identifier(node.name)
            instructions: List[AsmInstruction] = self.generate_instructions(node.body)
            return AsmFunction(name, instructions)

        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, not all nodes were visited")

    def generate_program(self, node: AST) -> None:
        """ program = Program(function_definition) """
        self.expect_next(node, AST)
        if isinstance(node, TacProgram):
            function_def: AsmFunctionDef = self.generate_function_def(node.function_def)
            self.asm_ast = AsmProgram(function_def)
        else:

            raise AssemblyGeneratorError(
                "An error occurred in assembly generation, not all nodes were visited")

    def generate_stack(self) -> None:
        self.stack_mngr.generate_stack(self.asm_ast)


def assembly_generation(tac_ast: AST) -> AST:

    assembly_generator = AssemblyGenerator()

    assembly_generator.generate_program(tac_ast)

    if not assembly_generator.asm_ast:
        raise AssemblyGeneratorError(
            "An error occurred in assembly generation, ASM was not generated")

    assembly_generator.generate_stack()

    return assembly_generator.asm_ast
