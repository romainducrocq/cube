from dataclasses import dataclass

from pycc.util.__ast import *

__all__ = [
    'CUnaryOp',
    'CComplement',
    'CNegate',
    'CBinaryOp',
    "CAdd",
    "CSubtract",
    "CMultiply",
    "CDivide",
    "CRemainder",
    "CBitAnd",
    "CBitOr",
    "CBitXor",
    "CBitShiftLeft",
    "CBitShiftRight",
    'CExp',
    'CConstant',
    'CUnary',
    'CBinary',
    'CStatement',
    'CReturn',
    'CFunctionDef',
    'CFunction',
    'CProgram'
]


class CUnaryOp(AST):
    """
    unary_operator = Complement
                   | Negate
    """
    pass


class CComplement(CUnaryOp):
    """ Complement """
    pass


class CNegate(CUnaryOp):
    """ Negate """
    pass


class CBinaryOp(AST):
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
    """
    pass


class CAdd(CBinaryOp):
    """ Add """
    pass


class CSubtract(CBinaryOp):
    """ Subtract """
    pass


class CMultiply(CBinaryOp):
    """ Multiply """
    pass


class CDivide(CBinaryOp):
    """ Divide """
    pass


class CRemainder(CBinaryOp):
    """ Remainder """
    pass


class CBitAnd(CBinaryOp):
    """ BitAnd """
    pass


class CBitOr(CBinaryOp):
    """ BitOr """
    pass


class CBitXor(CBinaryOp):
    """ BitXor """
    pass


class CBitShiftLeft(CBinaryOp):
    """ BitShiftLeft """
    pass


class CBitShiftRight(CBinaryOp):
    """ BitShiftRight """
    pass


class CExp(AST):
    """
    exp = Constant(int value)
        | Unary(unary_operator, exp)
        | Binary(binary_operator, exp, exp)
    """
    pass


@dataclass
class CConstant(CExp):
    """ Constant(int value) """
    value: TInt = None


@dataclass
class CUnary(CExp):
    """ Unary(unary_operator, exp) """
    unary_op: CUnaryOp = None
    exp: CExp = None


@dataclass
class CBinary(CExp):
    """ Binary(binary_operator, exp, exp) """
    binary_op: CBinaryOp = None
    exp_left: CExp = None
    exp_right: CExp = None


class CStatement(AST):
    """
    statement = Return(exp)
    """
    pass


@dataclass
class CReturn(CStatement):
    """ Return(exp) """
    exp: CExp = None


class CFunctionDef(AST):
    """
    function_definition = Function(identifier name, statement body)
    """
    pass


@dataclass
class CFunction(CFunctionDef):
    """ Function(identifier name, statement body) """
    name: TIdentifier = None
    body: CStatement = None


@dataclass
class CProgram(AST):
    """ AST = Program(function_definition) """
    function_def: CFunctionDef = None
