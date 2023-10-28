from typing import List
from dataclasses import dataclass

from pycc.util.__ast import *

__all__ = [
    'TacUnaryOp',
    'TacComplement',
    'TacNegate',
    'TacValue',
    'TacConstant',
    'TacVariable',
    'TacInstruction',
    'TacReturn',
    'TacUnary',
    'TacFunctionDef',
    'TacFunction',
    'TacProgram'
]


class TacUnaryOp(AST):
    """
    unary_operator = Complement
                   | Negate
    """
    pass


class TacComplement(TacUnaryOp):
    """ Complement """
    pass


class TacNegate(TacUnaryOp):
    """ Negate """
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


class TacFunctionDef(AST):
    """
    function_definition = Function(identifier, instruction* body)
    """
    pass


class TacFunction(TacFunctionDef):
    """ Function(identifier, instruction* body) """
    name: TIdentifier = None
    body: List[TacInstruction] = None


@dataclass
class TacProgram(AST):
    """ AST = Program(function_definition) """
    function_def: TacFunctionDef = None
