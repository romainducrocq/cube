from typing import List
from dataclasses import dataclass

from pycc.util.__ast import *

__all__ = [
    'TacUnaryOp',
    'TacComplement',
    'TacNegate',
    'TacNot',
    'TacBinaryOp',
    'TacAdd',
    'TacSubtract',
    'TacMultiply',
    'TacDivide',
    'TacRemainder',
    'TacBitAnd',
    'TacBitOr',
    'TacBitXor',
    'TacBitShiftLeft',
    'TacBitShiftRight',
    'TacEqual',
    'TacNotEqual',
    'TacLessThan',
    'TacLessOrEqual',
    'TacGreaterThan',
    'TacGreaterOrEqual',
    'TacValue',
    'TacConstant',
    'TacVariable',
    'TacInstruction',
    'TacReturn',
    'TacUnary',
    'TacBinary',
    'TacCopy',
    'TacJump',
    'TacJumpIfZero',
    'TacJumpIfNotZero',
    'TacLabel',
    'TacFunctionDef',
    'TacFunction',
    'TacProgram'
]


class TacUnaryOp(AST):
    """
    unary_operator = Complement
                   | Negate
                   | Not
    """
    pass


class TacComplement(TacUnaryOp):
    """ Complement """
    pass


class TacNegate(TacUnaryOp):
    """ Negate """
    pass


class TacNot(TacUnaryOp):
    """ Not """
    pass


class TacBinaryOp(AST):
    """
    binary_operator = Add
                    | Subtract
                    | Multiply
                    | Divide
                    | Remainder
                    | BitAnd
                    | BitOr
                    | BitXor
                    | BitShiftLeft
                    | BitShiftRight
                    | Equal
                    | NotEqual
                    | LessThan
                    | LessOrEqual
                    | GreaterThan
                    | GreaterOrEqual
    """
    pass


class TacAdd(TacBinaryOp):
    """ Add """
    pass


class TacSubtract(TacBinaryOp):
    """ Subtract """
    pass


class TacMultiply(TacBinaryOp):
    """ Multiply """
    pass


class TacDivide(TacBinaryOp):
    """ Divide """
    pass


class TacRemainder(TacBinaryOp):
    """ Remainder """
    pass


class TacBitAnd(TacBinaryOp):
    """ BitAnd """
    pass


class TacBitOr(TacBinaryOp):
    """ BitOr """
    pass


class TacBitXor(TacBinaryOp):
    """ BitXor """
    pass


class TacBitShiftLeft(TacBinaryOp):
    """ BitShiftLeft """
    pass


class TacBitShiftRight(TacBinaryOp):
    """ BitShiftRight """
    pass


class TacEqual(TacBinaryOp):
    """ Equal """
    pass


class TacNotEqual(TacBinaryOp):
    """ NotEqual """
    pass


class TacLessThan(TacBinaryOp):
    """ LessThan """
    pass


class TacLessOrEqual(TacBinaryOp):
    """ LessOrEqual """
    pass


class TacGreaterThan(TacBinaryOp):
    """ GreaterThan """
    pass


class TacGreaterOrEqual(TacBinaryOp):
    """ GreaterOrEqual """
    pass


class TacValue(AST):
    """
    val = Constant(int)
        | Var(identifier)
    """
    pass


@dataclass
class TacConstant(TacValue):
    """ Constant(int) """
    value: TInt = None


@dataclass
class TacVariable(TacValue):
    """ Var(identifier) """
    name: TIdentifier = None


class TacInstruction(AST):
    """
    instruction = Return(val)
                | Unary(unary_operator, val src, val dst)
                | Binary(binary_operator, val src1, val src2, val dst)
                | Copy(val src, val dst)
                | Jump(identifier target)
                | JumpIfZero(val condition, identifier target)
                | JumpIfNotZero(val condition, identifier target)
                | Label(identifier name)
    """
    pass


@dataclass
class TacReturn(TacInstruction):
    """ Return(val) """
    val: TacValue = None


@dataclass
class TacUnary(TacInstruction):
    """ Unary(unary_operator, val src, val dst) """
    unary_op: TacUnaryOp = None
    src: TacValue = None
    dst: TacValue = None


@dataclass
class TacBinary(TacInstruction):
    """ Binary(binary_operator, val src1, val src2, val dst) """
    binary_op: TacBinaryOp = None
    src1: TacValue = None
    src2: TacValue = None
    dst: TacValue = None


@dataclass
class TacCopy(TacInstruction):
    """ Copy(val src, val dst) """
    src: TacValue = None
    dst: TacValue = None


@dataclass
class TacJump(TacInstruction):
    """ Jump(identifier target) """
    target: TIdentifier = None


@dataclass
class TacJumpIfZero(TacInstruction):
    """ JumpIfZero(val condition, identifier target) """
    condition: TacValue = None
    target: TIdentifier = None


@dataclass
class TacJumpIfNotZero(TacInstruction):
    """ JumpIfNotZero(val condition, identifier target) """
    condition: TacValue = None
    target: TIdentifier = None


@dataclass
class TacLabel(TacInstruction):
    """ Label(identifier name) """
    name: TIdentifier = None


class TacFunctionDef(AST):
    """
    function_definition = Function(identifier, instruction* body)
    """
    pass


@dataclass
class TacFunction(TacFunctionDef):
    """ Function(identifier, instruction* body) """
    name: TIdentifier = None
    body: List[TacInstruction] = None


@dataclass
class TacProgram(AST):
    """ AST = Program(function_definition) """
    function_def: TacFunctionDef = None
