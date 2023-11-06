from typing import List
from dataclasses import dataclass

from pycc.util.__ast import *

__all__ = [
    'AsmReg',
    'AsmAx',
    'AsmCx',
    'AsmDx',
    'AsmR10',
    'AsmR11',
    'AsmCondCode',
    'AsmE',
    'AsmNE',
    'AsmG',
    'AsmGE',
    'AsmL',
    'AsmLE',
    'AsmOperand',
    'AsmImm',
    'AsmRegister',
    'AsmPseudo',
    'AsmStack',
    'AsmBinaryOp',
    'AsmAdd',
    'AsmSub',
    'AsmMult',
    'AsmBitAnd',
    'AsmBitOr',
    'AsmBitXor',
    'AsmBitShiftLeft',
    'AsmBitShiftRight',
    'AsmUnaryOp',
    'AsmNot',
    'AsmNeg',
    'AsmInstruction',
    'AsmMov',
    'AsmUnary',
    'AsmBinary',
    'AsmCmp',
    'AsmIdiv',
    'AsmCdq',
    'AsmJmp',
    'AsmJmpCC',
    'AsmSetCC',
    'AsmLabel',
    'AsmAllocStack',
    'AsmRet',
    'AsmFunctionDef',
    'AsmFunction',
    'AsmProgram'
]


class AsmReg(AST):
    """
    reg = AX
        | CX
        | DX
        | R10
        | R11
    """
    pass


class AsmAx(AsmReg):
    """ AX """
    pass


class AsmCx(AsmReg):
    """ CX """
    pass


class AsmDx(AsmReg):
    """ DX """
    pass


class AsmR10(AsmReg):
    """ R10 """
    pass


class AsmR11(AsmReg):
    """ R11 """
    pass


class AsmCondCode(AST):
    """
    cond_code = E
              | NE
              | G
              | GE
              | L
              | LE
    """
    pass


class AsmE(AsmCondCode):
    """ E """
    pass


class AsmNE(AsmCondCode):
    """ NE """
    pass


class AsmG(AsmCondCode):
    """ G """
    pass


class AsmGE(AsmCondCode):
    """ GE """
    pass


class AsmL(AsmCondCode):
    """ L """
    pass


class AsmLE(AsmCondCode):
    """ LE """
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
                    | BitAnd
                    | BitOr
                    | BitXor
                    | BitShiftLeft
                    | BitShiftRight
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


class AsmBitAnd(AsmBinaryOp):
    """ BitAnd """
    pass


class AsmBitOr(AsmBinaryOp):
    """ BitOr """
    pass


class AsmBitXor(AsmBinaryOp):
    """ BitXor """
    pass


class AsmBitShiftLeft(AsmBinaryOp):
    """ BitShiftLeft """
    pass


class AsmBitShiftRight(AsmBinaryOp):
    """ BitShiftRight """
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
                | Cmp(operand, operand)
                | Idiv(operand)
                | Cdq
                | Jmp(identifier)
                | JmpCC(cond_code, identifier)
                | SetCC(cond_code, operand)
                | Label(identifier)
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
    """ Binary(binary_operator binop, operand src, operand dst) """
    binary_op: AsmBinaryOp = None
    src: AsmOperand = None
    dst: AsmOperand = None


@dataclass
class AsmCmp(AsmInstruction):
    """ Cmp(operand src, operand dst) """
    src: AsmOperand = None
    dst: AsmOperand = None


@dataclass
class AsmIdiv(AsmInstruction):
    """ Idiv(operand src) """
    src: AsmOperand = None


class AsmCdq(AsmInstruction):
    """ Cdq """
    pass


@dataclass
class AsmJmp(AsmInstruction):
    """ Jmp(identifier target) """
    target: TIdentifier = None


@dataclass
class AsmJmpCC(AsmInstruction):
    """ JmpCC(cond_code cond_code, identifier target) """
    cond_code: AsmCondCode = None
    target: TIdentifier = None


@dataclass
class AsmSetCC(AsmInstruction):
    """ SetCC(cond_code cond_code, operand dst) """
    cond_code: AsmCondCode = None
    dst: AsmOperand = None


@dataclass
class AsmLabel(AsmInstruction):
    """ Label(identifier name) """
    name: TIdentifier = None


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
