from typing import List
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
    var_mngr: VariableManager = VariableManager()

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

    def represent_unary_op(self, node: AST) -> TacUnaryOp:
        """ unary_operator = Complement | Negate """
        self.expect_next(node, CUnaryOp)
        if isinstance(node, CComplement):
            return TacComplement()
        if isinstance(node, CNegate):
            return TacNegate()

        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, not all nodes were visited")

    def represent_value(self, node: AST = None, var: AST = None, last: bool = False,
                        instructions: List[TacInstruction] = None) -> TacValue:
        """ val = Constant(int) | Var(identifier) """
        self.expect_next(node, CExp,
                         type(None))
        if isinstance(node, CConstant):
            value: TInt = self.represent_int(node.value)
            return TacConstant(value)
        if isinstance(node, (type(None), CUnary)):
            if isinstance(node, CUnary):
                self.represent_instruction(node, instructions)
            identifier: TIdentifier = self.var_mngr.represent_variable_identifier(var, last)
            return TacVariable(identifier)

        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, not all nodes were visited")

    def represent_instruction(self, iter_node: AST, instructions: List[TacInstruction]) -> None:
        """ instruction = Return(val) | Unary(unary_operator, val src, val dst) """
        self.expect_next(iter_node, CStatement,
                         CExp)
        if isinstance(iter_node, CReturn):
            val: TacValue = self.represent_value(node=iter_node.exp, last=True, instructions=instructions)
            instructions.append(TacReturn(val))
        elif isinstance(iter_node, CUnary):
            unary_op: TacUnaryOp = self.represent_unary_op(iter_node.unary_op)
            src: TacValue = self.represent_value(node=iter_node.exp, last=True, instructions=instructions)
            dst: TacValue = self.represent_value(var=iter_node.exp)
            instructions.append(TacUnary(unary_op, src, dst))
        else:

            raise ThreeAddressCodeGeneratorError(
                "An error occurred in three address code representation, not all nodes were visited")

    def represent_instructions(self, node: AST) -> List[TacInstruction]:

        instructions: List[TacInstruction] = []

        self.represent_instruction(node, instructions)
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
