from typing import List, Union
from copy import deepcopy

from ccc.util.__ast import *
from ccc.intermediate.tac_ast import *
from ccc.assembly.asm_ast import *
from ccc.assembly.register import REGISTER_KIND, RegisterManager
from ccc.assembly.stack import StackManager

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

    def generate_condition_code(self, node: AST) -> AsmCondCode:
        self.expect_next(node, TacEqual,
                         TacNotEqual,
                         TacLessThan,
                         TacLessOrEqual,
                         TacGreaterThan,
                         TacGreaterOrEqual)
        if isinstance(node, TacEqual):
            return AsmE()
        if isinstance(node, TacNotEqual):
            return AsmNE()
        if isinstance(node, TacLessThan):
            return AsmL()
        if isinstance(node, TacLessOrEqual):
            return AsmLE()
        if isinstance(node, TacGreaterThan):
            return AsmG()
        if isinstance(node, TacGreaterOrEqual):
            return AsmGE()

    def generate_binary_op(self, node: AST) -> AsmBinaryOp:
        """ binary_operator = Add | Sub | Mult | BitAnd | BitOr | BitXor | BitShiftLeft | BitShiftRight"""
        self.expect_next(node, TacAdd,
                         TacSubtract,
                         TacMultiply,
                         TacBitAnd,
                         TacBitOr,
                         TacBitXor,
                         TacBitShiftLeft,
                         TacBitShiftRight)
        if isinstance(node, TacAdd):
            return AsmAdd()
        if isinstance(node, TacSubtract):
            return AsmSub()
        if isinstance(node, TacMultiply):
            return AsmMult()
        if isinstance(node, TacBitAnd):
            return AsmBitAnd()
        if isinstance(node, TacBitOr):
            return AsmBitOr()
        if isinstance(node, TacBitXor):
            return AsmBitXor()
        if isinstance(node, TacBitShiftLeft):
            return AsmBitShiftLeft()
        if isinstance(node, TacBitShiftRight):
            return AsmBitShiftRight()

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

    def generate_list_instructions(self, list_node: list) -> List[AsmInstruction]:
        """ instruction = Mov(operand src, operand dst) | Unary(unary_operator, operand) | Cmp(operand, operand)
                        | Idiv(operand) | Cdq | Jmp(identifier) | JmpCC(cond_code, identifier)
                        | SetCC(cond_code, operand) | Label(identifier) | AllocateStack(int) | Ret """
        self.expect_next(list_node, list)

        instructions: List[AsmInstruction] = []

        def generate_instructions(node: AST) -> None:
            self.expect_next(node, TacInstruction)
            if isinstance(node, TacReturn):
                src: AsmOperand = self.generate_operand(node.val)
                dst: AsmOperand = self.generate_operand(REGISTER_KIND.AX)
                instructions.append(AsmMov(src, dst))
                instructions.append(AsmRet())
            elif isinstance(node, TacUnary):
                if isinstance(node.unary_op, TacNot):
                    imm_zero: AsmOperand = AsmImm(TInt(0))
                    cond_code: AsmCondCode = self.generate_condition_code(TacEqual())
                    src: AsmOperand = self.generate_operand(node.src)
                    cmp_dst: AsmOperand = self.generate_operand(node.dst)
                    instructions.append(AsmCmp(imm_zero, src))
                    instructions.append(AsmMov(deepcopy(imm_zero), cmp_dst))
                    instructions.append(AsmSetCC(cond_code, deepcopy(cmp_dst)))
                else:  # if isinstance(node.unary_op, (TacComplement, TacNegate)):
                    unary_op: AsmUnaryOp = self.generate_unary_op(node.unary_op)
                    src: AsmOperand = self.generate_operand(node.src)
                    src_dst: AsmOperand = self.generate_operand(node.dst)
                    instructions.append(AsmMov(src, src_dst))
                    instructions.append(AsmUnary(unary_op, deepcopy(src_dst)))
            elif isinstance(node, TacBinary):
                if isinstance(node.binary_op, (TacAdd, TacSubtract, TacMultiply, TacBitAnd, TacBitOr, TacBitXor,
                                               TacBitShiftLeft, TacBitShiftRight)):
                    binary_op: AsmBinaryOp = self.generate_binary_op(node.binary_op)
                    src1: AsmOperand = self.generate_operand(node.src1)
                    src2: AsmOperand = self.generate_operand(node.src2)
                    src1_dst: AsmOperand = self.generate_operand(node.dst)
                    instructions.append(AsmMov(src1, src1_dst))
                    instructions.append(AsmBinary(binary_op, src2, deepcopy(src1_dst)))
                elif isinstance(node.binary_op, (TacDivide, TacRemainder)):
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
                else:  # if isinstance(node.binary_op, (TacEqual, TacNotEqual, TacLessThan, TacLessOrEqual,
                    #                  TacGreaterThan, TacGreaterOrEqual)):
                    imm_zero: AsmOperand = AsmImm(TInt(0))
                    cond_code: AsmCondCode = self.generate_condition_code(node.binary_op)
                    src1: AsmOperand = self.generate_operand(node.src1)
                    src2: AsmOperand = self.generate_operand(node.src2)
                    cmp_dst: AsmOperand = self.generate_operand(node.dst)
                    instructions.append(AsmCmp(src2, src1))
                    instructions.append(AsmMov(imm_zero, cmp_dst))
                    instructions.append(AsmSetCC(cond_code, deepcopy(cmp_dst)))
            elif isinstance(node, TacJump):
                target: TIdentifier = self.generate_identifier(node.target)
                instructions.append(AsmJmp(target))
            elif isinstance(node, (TacJumpIfZero, TacJumpIfNotZero)):
                imm_zero: AsmOperand = AsmImm(TInt(0))
                if isinstance(node, TacJumpIfZero):
                    cond_code: AsmCondCode = self.generate_condition_code(TacEqual())
                else:
                    cond_code: AsmCondCode = self.generate_condition_code(TacNotEqual())
                target: TIdentifier = self.generate_identifier(node.target)
                condition: AsmOperand = self.generate_operand(node.condition)
                instructions.append(AsmCmp(imm_zero, condition))
                instructions.append(AsmJmpCC(cond_code, target))
            elif isinstance(node, TacCopy):
                src: AsmOperand = self.generate_operand(node.src)
                dst: AsmOperand = self.generate_operand(node.dst)
                instructions.append(AsmMov(src, dst))
            elif isinstance(node, TacLabel):
                name: TIdentifier = self.generate_identifier(node.name)
                instructions.append(AsmLabel(name))
            else:

                raise AssemblyGeneratorError(
                    "An error occurred in assembly generation, not all nodes were visited")

        for item_node in list_node:
            generate_instructions(item_node)

        return instructions

    def generate_function_def(self, node: AST) -> AsmFunctionDef:
        """ function_definition = Function(identifier name, instruction* instructions) """
        self.expect_next(node, TacFunctionDef)
        if isinstance(node, TacFunction):
            name: TIdentifier = self.generate_identifier(node.name)
            instructions: List[AsmInstruction] = self.generate_list_instructions(node.body)
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
