from typing import List
from dataclasses import dataclass

from pycc.util.__ast import *

__all__ = [
    'AsmReg',
    'AsmAx',
    'AsmDX',
    'AsmR10',
    'AsmR11',
    'AsmOperand',
    'AsmImm',
    'AsmRegister',
    'AsmPseudo',
    'AsmStack',
    'AsmBinaryOp',
    'AsmAdd',
    'AsmSub',
    'AsmMult',
    'AsmUnaryOp',
    'AsmNot',
    'AsmNeg',
    'AsmInstruction',
    'AsmMov',
    'AsmUnary',
    'AsmBinary',
    'AsmIdiv',
    'AsmCdq',
    'AsmAllocStack',
    'AsmRet',
    'AsmFunctionDef',
    'AsmFunction',
    'AsmProgram'
]


class AsmReg(AST):
    """
    reg = AX
        | DX
        | R10
        | R11
    """
    pass


class AsmAx(AsmReg):
    """ AX """
    pass


class AsmDX(AsmReg):
    """ DX """
    pass


class AsmR10(AsmReg):
    """ R10 """
    pass


class AsmR11(AsmReg):
    """ R11 """
    pass


class AsmOperand(AST):
    """
    operand = Imm(int)
            | Reg(reg)
            | Pseudo(identifier)
            | Stack(int)
    """
    pass


@dataclass
class AsmImm(AsmOperand):
    """ Imm(int value) """
    value: TInt = None


@dataclass
class AsmRegister(AsmOperand):
    """ Register(reg register) """
    register: AsmReg = None


@dataclass
class AsmPseudo(AsmOperand):
    """ Pseudo(identifier name) """
    name: TIdentifier = None


@dataclass
class AsmStack(AsmOperand):
    """ Stack(int value) """
    value: TInt = None


class AsmBinaryOp(AST):
    """
    binary_operator = Add
                    | Sub
                    | Mult
    """
    pass


class AsmAdd(AsmBinaryOp):
    """ Add """
    pass


class AsmSub(AsmBinaryOp):
    """ Sub """
    pass


class AsmMult(AsmBinaryOp):
    """ Mult """
    pass


class AsmUnaryOp(AST):
    """
    unary_operator = Not
                   | Neg
    """
    pass


class AsmNot(AsmUnaryOp):
    """ Not """
    pass


class AsmNeg(AsmUnaryOp):
    """ Neg """
    pass


class AsmInstruction(AST):
    """
    instruction = Mov(operand src, operand dst)
                | Unary(unary_operator, operand)
                | Binary(binary_operator, operand, operand)
                | Idiv(operand)
                | Cdq
                | AllocateStack(int)
                | Ret
    """
    pass


@dataclass
class AsmMov(AsmInstruction):
    """ Mov(operand src, operand dst) """
    src: AsmOperand = None
    dst: AsmOperand = None


@dataclass
class AsmUnary(AsmInstruction):
    """ Unary(unary_operator unop, operand dst) """
    unary_op: AsmUnaryOp = None
    dst: AsmOperand = None


@dataclass
class AsmBinary(AsmInstruction):
    """ Binary(binary_operator binop, operand src2, operand dst) """
    binary_op: AsmBinaryOp = None
    src2: AsmOperand = None
    dst: AsmOperand = None


@dataclass
class AsmIdiv(AsmInstruction):
    """ Idiv(operand src2) """
    src2: AsmOperand = None


class AsmCdq(AsmInstruction):
    """ Cdq """
    pass


@dataclass
class AsmAllocStack(AsmInstruction):
    """ AllocateStack(int value) """
    value: TInt = None


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
