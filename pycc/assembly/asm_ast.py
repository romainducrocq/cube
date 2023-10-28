from typing import List
from dataclasses import dataclass

from pycc.util.__ast import *

__all__ = [
    'AsmOperand',
    'AsmImm',
    'AsmRegister',
    'AsmInstruction',
    'AsmMov',
    'AsmRet',
    'AsmFunctionDef',
    'AsmFunction',
    'AsmProgram'
]


class AsmOperand(AST):
    """
    operand = Imm(int value) | Register
    """
    pass


@dataclass
class AsmImm(AsmOperand):
    """ Imm(int value) """
    value: TInt = None


class AsmRegister(AsmOperand):
    """ Register """
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
    """
    function_definition = Function(identifier name, instruction* instructions)
    """
    pass


@dataclass
class AsmFunction(AsmFunctionDef):
    """ Function(identifier name, instruction* instructions) """
    name: TIdentifier = None
    instructions: List[AsmInstruction] = None


@dataclass
class AsmProgram(AST):
    """ AST = Program(function_definition) """
    function_def: AsmFunctionDef = None
