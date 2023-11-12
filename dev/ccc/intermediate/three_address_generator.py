from typing import List, Optional
from copy import deepcopy

from ccc.util.__ast import *
from ccc.parser.c_ast import *
from ccc.intermediate.tac_ast import *
from ccc.intermediate.name import NameManager

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
        """ binary_operator = Add | Subtract | Multiply | Divide | Remainder | BitAnd | BitOr | BitXor
                            | BitShiftLeft | BitShiftRight | Equal | NotEqual | LessThan | LessOrEqual
                            | GreaterThan | GreaterOrEqual """
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
        if isinstance(node, CBitAnd):
            return TacBitAnd()
        if isinstance(node, CBitOr):
            return TacBitOr()
        if isinstance(node, CBitXor):
            return TacBitXor()
        if isinstance(node, CBitShiftLeft):
            return TacBitShiftLeft()
        if isinstance(node, CBitShiftRight):
            return TacBitShiftRight()
        if isinstance(node, CEqual):
            return TacEqual()
        if isinstance(node, CNotEqual):
            return TacNotEqual()
        if isinstance(node, CLessThan):
            return TacLessThan()
        if isinstance(node, CLessOrEqual):
            return TacLessOrEqual()
        if isinstance(node, CGreaterThan):
            return TacGreaterThan()
        if isinstance(node, CGreaterOrEqual):
            return TacGreaterOrEqual()

        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, not all nodes were visited")

    def represent_unary_op(self, node: AST) -> TacUnaryOp:
        """ unary_operator = Complement | Negate | Not """
        self.expect_next(node, CUnaryOp)
        if isinstance(node, CComplement):
            return TacComplement()
        if isinstance(node, CNegate):
            return TacNegate()
        if isinstance(node, CNot):
            return TacNot()

        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, not all nodes were visited")

    def represent_value(self, node: AST, outer: bool = True) -> TacValue:
        """ val = Constant(int) | Var(identifier) """
        self.expect_next(node, CExp)
        if outer:
            if isinstance(node, CConstant):
                value: TInt = self.represent_int(node.value)
                return TacConstant(value)
            if isinstance(node, CVar):
                name: TIdentifier = self.represent_identifier(node.name)
                return TacVariable(name)

            raise ThreeAddressCodeGeneratorError(
                "An error occurred in three address code representation, not all nodes were visited")

        name: TIdentifier = NameManager.represent_variable_identifier(node)
        return TacVariable(name)

    def represent_list_instructions(self, list_node: list) -> List[TacInstruction]:
        """ instruction = Return(val) | Unary(unary_operator, val src, val dst)
                    | Binary(binary_operator, val src1, val src2, val dst) | Copy(val src, val dst)
                    | Jump(identifier target) | JumpIfZero(val condition, identifier target)
                    | JumpIfNotZero(val condition, identifier target) | Label(identifier name) """
        self.expect_next(list_node, list)

        instructions: List[TacInstruction] = []

        def represent_instructions(node: AST) -> Optional[TacValue]:
            self.expect_next(node, CDeclaration, CStatement,
                             CExp)
            if isinstance(node, CDecl):
                if node.init:
                    src: TacValue = represent_instructions(node.init)
                    dst: TacValue = self.represent_value(CVar(node.name))
                    instructions.append(TacCopy(src, dst))
                return None
            if isinstance(node, CReturn):
                val: TacValue = represent_instructions(node.exp)
                instructions.append(TacReturn(val))
                return None
            if isinstance(node, CExpression):
                _ = represent_instructions(node.exp)
                return None
            if isinstance(node, CNull):
                return None
            if isinstance(node, (CVar, CConstant)):
                val: TacValue = self.represent_value(node)
                return val
            if isinstance(node, CUnary):
                src: TacValue = represent_instructions(node.exp)
                dst: TacValue = self.represent_value(node.exp, outer=False)
                unary_op: TacUnaryOp = self.represent_unary_op(node.unary_op)
                instructions.append(TacUnary(unary_op, src, dst))
                return deepcopy(dst)
            if isinstance(node, CBinary):
                if isinstance(node.binary_op, CAnd):
                    is_true: TacValue = TacConstant(TInt(1))
                    is_false: TacValue = TacConstant(TInt(0))
                    label_true: TIdentifier = NameManager.represent_label_identifier("and_true")
                    label_false: TIdentifier = NameManager.represent_label_identifier("and_false")
                    src1: TacValue = represent_instructions(node.exp_left)
                    instructions.append(TacJumpIfZero(src1, label_false))
                    src2: TacValue = represent_instructions(node.exp_right)
                    instructions.append(TacJumpIfZero(src2, deepcopy(label_false)))
                    dst: TacValue = self.represent_value(node.exp_left, outer=False)
                    instructions.append(TacCopy(is_true, dst))
                    instructions.append(TacJump(label_true))
                    instructions.append(TacLabel(deepcopy(label_false)))
                    instructions.append(TacCopy(is_false, deepcopy(dst)))
                    instructions.append(TacLabel(deepcopy(label_true)))
                    return deepcopy(dst)
                elif isinstance(node.binary_op, COr):
                    is_true: TacValue = TacConstant(TInt(1))
                    is_false: TacValue = TacConstant(TInt(0))
                    label_true: TIdentifier = NameManager.represent_label_identifier("or_true")
                    label_false: TIdentifier = NameManager.represent_label_identifier("or_false")
                    src1: TacValue = represent_instructions(node.exp_left)
                    instructions.append(TacJumpIfNotZero(src1, label_true))
                    src2: TacValue = represent_instructions(node.exp_right)
                    instructions.append(TacJumpIfNotZero(src2, deepcopy(label_true)))
                    dst: TacValue = self.represent_value(node.exp_left, outer=False)
                    instructions.append(TacCopy(is_false, dst))
                    instructions.append(TacJump(label_false))
                    instructions.append(TacLabel(deepcopy(label_true)))
                    instructions.append(TacCopy(is_true, deepcopy(dst)))
                    instructions.append(TacLabel(deepcopy(label_false)))
                    return deepcopy(dst)
                else:
                    src1: TacValue = represent_instructions(node.exp_left)
                    src2: TacValue = represent_instructions(node.exp_right)
                    dst: TacValue = self.represent_value(node.exp_left, outer=False)
                    binary_op: TacBinaryOp = self.represent_binary_op(node.binary_op)
                    instructions.append(TacBinary(binary_op, src1, src2, dst))
                    return deepcopy(dst)
            if isinstance(node, CAssignment):
                src: TacValue = represent_instructions(node.exp_right)
                dst: TacValue = self.represent_value(node.exp_left)
                instructions.append(TacCopy(src, dst))
                return deepcopy(dst)
            if isinstance(node, CAssignmentCompound):
                src1: TacValue = represent_instructions(node.exp_left)
                src2: TacValue = represent_instructions(node.exp_right)
                dst_src: TacValue = self.represent_value(node.exp_left, outer=False)
                binary_op: TacBinaryOp = self.represent_binary_op(node.binary_op)
                instructions.append(TacBinary(binary_op, src1, src2, dst_src))
                dst: TacValue = self.represent_value(node.exp_left)
                instructions.append(TacCopy(deepcopy(dst_src), dst))
                return deepcopy(dst)

            raise ThreeAddressCodeGeneratorError(
                "An error occurred in three address code representation, not all nodes were visited")

        for item_node in list_node:
            self.expect_next(item_node, CBlockItem)
            if isinstance(item_node, CS):
                represent_instructions(item_node.statement)
            elif isinstance(item_node, CD):
                represent_instructions(item_node.declaration)
            else:

                raise ThreeAddressCodeGeneratorError(
                    "An error occurred in three address code representation, not all nodes were visited")

        instructions.append(TacReturn(TacConstant(TInt(0))))
        return instructions

    def represent_function_def(self, node: AST) -> TacFunctionDef:
        """ function_definition = Function(identifier, instruction* body) """
        self.expect_next(node, CFunctionDef)
        if isinstance(node, CFunction):
            name: TIdentifier = self.represent_identifier(node.name)
            instructions: List[TacInstruction] = self.represent_list_instructions(node.body)
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
