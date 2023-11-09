from typing import List, Optional
from dataclasses import dataclass

from pycc.util.__ast import *

__all__ = [
    'CUnaryOp',
    'CComplement',
    'CNegate',
    'CNot',
    'CBinaryOp',
    'CAdd',
    'CSubtract',
    'CMultiply',
    'CDivide',
    'CRemainder',
    'CBitAnd',
    'CBitOr',
    'CBitXor',
    'CBitShiftLeft',
    'CBitShiftRight',
    'CAnd',
    'COr',
    'CEqual',
    'CNotEqual',
    'CLessThan',
    'CLessOrEqual',
    'CGreaterThan',
    'CGreaterOrEqual',
    'CExp',
    'CConstant',
    'CVar',
    'CUnary',
    'CBinary',
    'CAssignment',
    'CStatement',
    'CReturn',
    'CExpression',
    'CNull',
    'CDeclaration',
    'CDecl',
    'CBlockItem',
    'CS',
    'CD',
    'CFunctionDef',
    'CFunction',
    'CProgram'
]


class CUnaryOp(AST):
    """
    unary_operator = Complement
                   | Negate
                   | Not
    """
    pass


class CComplement(CUnaryOp):
    """ Complement """
    pass


class CNegate(CUnaryOp):
    """ Negate """
    pass


class CNot(CUnaryOp):
    """ Not """
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
                    | And
                    | Or
                    | Equal
                    | NotEqual
                    | LessThan
                    | LessOrEqual
                    | GreaterThan
                    | GreaterOrEqual
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


class CAnd(CBinaryOp):
    """ And """
    pass


class COr(CBinaryOp):
    """ Or """
    pass


class CEqual(CBinaryOp):
    """ Equal """
    pass


class CNotEqual(CBinaryOp):
    """ NotEqual """
    pass


class CLessThan(CBinaryOp):
    """ LessThan """
    pass


class CLessOrEqual(CBinaryOp):
    """ LessOrEqual """
    pass


class CGreaterThan(CBinaryOp):
    """ GreaterThan """
    pass


class CGreaterOrEqual(CBinaryOp):
    """ GreaterOrEqual """
    pass


class CExp(AST):
    """
    exp = Constant(int value)
        | Var(identifier)
        | Unary(unary_operator, exp)
        | Binary(binary_operator, exp, exp)
        | Assignment(exp, exp)
    """
    pass


@dataclass
class CConstant(CExp):
    """ Constant(int value) """
    value: TInt = None


@dataclass
class CVar(CExp):
    """ Var(identifier name) """
    name: TIdentifier = None


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


@dataclass
class CAssignment(CExp):
    """ Assignment(exp, exp) """
    exp_left: CExp = None
    exp_right: CExp = None


class CStatement(AST):
    """
    statement = Return(exp)
              | Expression(exp)
              | Null
    """
    pass


@dataclass
class CReturn(CStatement):
    """ Return(exp) """
    exp: CExp = None


@dataclass
class CExpression(CStatement):
    """ Expression(exp) """
    exp: CExp = None


class CNull(CStatement):
    """ Null """
    pass


class CDeclaration(AST):
    """
    declaration = Declaration(identifier, exp?)
    """
    pass


@dataclass
class CDecl(CDeclaration):
    """ Declaration(identifier name, exp? init) """
    name: TIdentifier = None
    init: Optional[CExp] = None


class CBlockItem(AST):
    """
    block_item = S(statement)
               | D(declaration)
    """
    pass


@dataclass
class CS(CBlockItem):
    """ S(statement) """
    statement: CStatement = None


@dataclass
class CD(CBlockItem):
    """ D(declaration) """
    declaration: CDeclaration = None


class CFunctionDef(AST):
    """
    function_definition = Function(identifier, block_item*)
    """
    pass


@dataclass
class CFunction(CFunctionDef):
    """ Function(identifier name, block_item* body) """
    name: TIdentifier = None
    body: List[CBlockItem] = None


@dataclass
class CProgram(AST):
    """ AST = Program(function_definition) """
    function_def: CFunctionDef = None
