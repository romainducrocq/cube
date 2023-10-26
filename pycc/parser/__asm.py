from typing import List
from dataclasses import dataclass

from pycc.parser.__ast import AST


class AsmOperand(AST):
    """
    operand = Imm(int) | Register
    """
    pass


@dataclass
class AsmImm(AsmOperand):
    """ Imm(int value) """
    value: int = None


class AsmRegister(AsmOperand):
    """
    Register
    """
    pass


class AsmInstruction(AST):
    """
    instruction = Mov(operand src, operand dst) | Ret
    """
    pass


@dataclass
class AsmMov(AsmInstruction):
    """ Mov(operand src, operand dst) """
    src: AsmOperand = None
    dst: AsmOperand = None


class AsmRet(AsmInstruction):
    """ Ret """
    pass


class AsmFunctionDef(AST):
    """ function_definition = Function(identifier name, instruction* instructions) """
    pass


class AsmFunction(AsmFunctionDef):
    """ Function(identifier name, instruction* instructions) """
    identifier: str = None
    instructions: List[AsmInstruction] = []
