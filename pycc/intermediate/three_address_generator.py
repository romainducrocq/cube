from typing import List, Optional
from copy import deepcopy

from pycc.util.__ast import *
from pycc.parser.c_ast import *
from pycc.intermediate.tac_ast import *
from pycc.intermediate.variable import VariableManager

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

    def represent_identifier(self, node: AST) -> TIdentifier:
        """ <identifier> = Built-in identifier type """
        self.expect_next(node, TIdentifier)
        return TIdentifier(deepcopy(node.str_t))

    def represent_int(self, node: AST) -> TInt:
        """ <int> = Built-in int type """
        self.expect_next(node, TInt)
        return TInt(deepcopy(node.int_t))

    def represent_binary_op(self, node: AST) -> TacBinaryOp:
        """ binary_operator = Add | Subtract | Multiply | Divide | Remainder """
        self.expect_next(node, CBinaryOp)
        if isinstance(node, CAdd):
            return TacAdd()
        if isinstance(node, CSubtract):
            return TacSubtract()
        if isinstance(node, CMultiply):
            return TacMultiply()
        if isinstance(node, CDivide):
            return TacDivide()
        if isinstance(node, CRemainder):
            return TacRemainder()

        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, not all nodes were visited")

    def represent_unary_op(self, node: AST) -> TacUnaryOp:
        """ unary_operator = Complement | Negate """
        self.expect_next(node, CUnaryOp)
        if isinstance(node, CComplement):
            return TacComplement()
        if isinstance(node, CNegate):
            return TacNegate()

        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, not all nodes were visited")

    def represent_value(self, node: AST, outer: bool = True) -> TacValue:
        """ val = Constant(int) | Var(identifier) """
        self.expect_next(node, CExp)
        if outer:
            if isinstance(node, CConstant):
                value: TInt = self.represent_int(node.value)
                return TacConstant(value)

            raise ThreeAddressCodeGeneratorError(
                "An error occurred in three address code representation, not all nodes were visited")

        identifier: TIdentifier = VariableManager.represent_variable_identifier(node)
        return TacVariable(identifier)

    def represent_instruction(self, node: AST, instructions: List[TacInstruction]) -> Optional[TacValue]:
        """ instruction = Return(val) | Unary(unary_operator, val src, val dst) |
                          Binary(binary_operator, val src1, val src2, val dst) """
        self.expect_next(node, CStatement,
                         CExp)
        if isinstance(node, CReturn):
            val = self.represent_instruction(node.exp, instructions)
            instructions.append(TacReturn(val))
            return None
        if isinstance(node, CConstant):
            val: TacValue = self.represent_value(node)
            return val
        if isinstance(node, CUnary):
            src: TacValue = self.represent_instruction(node.exp, instructions)
            dst: TacValue = self.represent_value(node.exp, outer=False)
            unary_op: TacUnaryOp = self.represent_unary_op(node.unary_op)
            instructions.append(TacUnary(unary_op, src, dst))
            return deepcopy(dst)
        if isinstance(node, CBinary):
            src1: TacValue = self.represent_instruction(node.exp_left, instructions)
            src2: TacValue = self.represent_instruction(node.exp_right, instructions)
            dst: TacValue = self.represent_value(node.exp_left, outer=False)
            binary_op: TacBinaryOp = self.represent_binary_op(node.binary_op)
            instructions.append(TacBinary(binary_op, src1, src2, dst))
            return deepcopy(dst)

        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, not all nodes were visited")

    def represent_instructions(self, node: AST) -> List[TacInstruction]:

        instructions: List[TacInstruction] = []

        _ = self.represent_instruction(node, instructions)
        return instructions

    def represent_function_def(self, node: AST) -> TacFunctionDef:
        """ function_definition = Function(identifier, instruction* body) """
        self.expect_next(node, CFunctionDef)
        if isinstance(node, CFunction):
            name: TIdentifier = self.represent_identifier(node.name)
            instructions: List[TacInstruction] = self.represent_instructions(node.body)
            return TacFunction(name, instructions)

        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, not all nodes were visited")

    def represent_program(self, node: AST) -> None:
        """ AST = Program(function_definition) """
        self.expect_next(node, AST)
        if isinstance(node, CProgram):
            function_def: TacFunctionDef = self.represent_function_def(node.function_def)
            self.tac_ast = TacProgram(function_def)
        else:

            raise ThreeAddressCodeGeneratorError(
                "An error occurred in three address code representation, not all nodes were visited")


def three_address_code_representation(c_ast: AST) -> AST:

    three_address_code_generator = ThreeAddressCodeGenerator()

    three_address_code_generator.represent_program(c_ast)

    if not three_address_code_generator.tac_ast:
        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, ASM was not generated")

    return three_address_code_generator.tac_ast
