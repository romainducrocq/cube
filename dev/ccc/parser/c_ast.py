from typing import List, Optional

from ccc.util.__ast import *

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
    'CAssignmentCompound',
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
    _fields = ()


class CComplement(CUnaryOp):
    """ Complement """
    _fields = ()


class CNegate(CUnaryOp):
    """ Negate """
    _fields = ()


class CNot(CUnaryOp):
    """ Not """
    _fields = ()


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
    _fields = ()


class CAdd(CBinaryOp):
    """ Add """
    _fields = ()


class CSubtract(CBinaryOp):
    """ Subtract """
    _fields = ()


class CMultiply(CBinaryOp):
    """ Multiply """
    _fields = ()


class CDivide(CBinaryOp):
    """ Divide """
    _fields = ()


class CRemainder(CBinaryOp):
    """ Remainder """
    _fields = ()


class CBitAnd(CBinaryOp):
    """ BitAnd """
    _fields = ()


class CBitOr(CBinaryOp):
    """ BitOr """
    _fields = ()


class CBitXor(CBinaryOp):
    """ BitXor """
    _fields = ()


class CBitShiftLeft(CBinaryOp):
    """ BitShiftLeft """
    _fields = ()


class CBitShiftRight(CBinaryOp):
    """ BitShiftRight """
    _fields = ()


class CAnd(CBinaryOp):
    """ And """
    _fields = ()


class COr(CBinaryOp):
    """ Or """
    _fields = ()


class CEqual(CBinaryOp):
    """ Equal """
    _fields = ()


class CNotEqual(CBinaryOp):
    """ NotEqual """
    _fields = ()


class CLessThan(CBinaryOp):
    """ LessThan """
    _fields = ()


class CLessOrEqual(CBinaryOp):
    """ LessOrEqual """
    _fields = ()


class CGreaterThan(CBinaryOp):
    """ GreaterThan """
    _fields = ()


class CGreaterOrEqual(CBinaryOp):
    """ GreaterOrEqual """
    _fields = ()


class CExp(AST):
    """
    exp = Constant(int value)
        | Var(identifier)
        | Unary(unary_operator, exp)
        | Binary(binary_operator, exp, exp)
        | Assignment(exp, exp)
        | AssignmentCompound(binary_operator, exp, exp)
    """
    _fields = ()


class CConstant(CExp):
    """ Constant(int value) """
    value: TInt = None
    _fields = ('value',)

    def __init__(self, value: TInt):
        self.value = value


class CVar(CExp):
    """ Var(identifier name) """
    name: TIdentifier = None
    _fields = ('name',)

    def __init__(self, name: TIdentifier):
        self.name = name


class CUnary(CExp):
    """ Unary(unary_operator, exp) """
    unary_op: CUnaryOp = None
    exp: CExp = None
    _fields = ('unary_op', 'exp')

    def __init__(self, unary_op: CUnaryOp, exp: CExp):
        self.unary_op = unary_op
        self.exp = exp


class CBinary(CExp):
    """ Binary(binary_operator, exp, exp) """
    binary_op: CBinaryOp = None
    exp_left: CExp = None
    exp_right: CExp = None
    _fields = ('binary_op', 'exp_left', 'exp_right')

    def __init__(self, binary_op: CBinaryOp, exp_left: CExp, exp_right: CExp):
        self.binary_op = binary_op
        self.exp_left = exp_left
        self.exp_right = exp_right


class CAssignment(CExp):
    """ Assignment(exp, exp) """
    exp_left: CExp = None
    exp_right: CExp = None
    _fields = ('exp_left', 'exp_right')

    def __init__(self, exp_left: CExp, exp_right: CExp):
        self.exp_left = exp_left
        self.exp_right = exp_right


class CAssignmentCompound(CExp):
    """ AssignmentCompound(binary_operator, exp, exp) """
    binary_op: CBinaryOp = None
    exp_left: CExp = None
    exp_right: CExp = None
    _fields = ('binary_op', 'exp_left', 'exp_right')

    def __init__(self, binary_op: CBinaryOp, exp_left: CExp, exp_right: CExp):
        self.binary_op = binary_op
        self.exp_left = exp_left
        self.exp_right = exp_right


class CStatement(AST):
    """
    statement = Return(exp)
              | Expression(exp)
              | Null
    """
    _fields = ()


class CReturn(CStatement):
    """ Return(exp) """
    exp: CExp = None
    _fields = ('exp',)

    def __init__(self, exp: CExp):
        self.exp = exp


class CExpression(CStatement):
    """ Expression(exp) """
    exp: CExp = None
    _fields = ('exp',)

    def __init__(self, exp: CExp):
        self.exp = exp


class CNull(CStatement):
    """ Null """
    _fields = ()


class CDeclaration(AST):
    """
    declaration = Declaration(identifier, exp?)
    """
    _fields = ()


class CDecl(CDeclaration):
    """ Declaration(identifier name, exp? init) """
    name: TIdentifier = None
    init: Optional[CExp] = None
    _fields = ('name', 'init')

    def __init__(self, name: TIdentifier, init: Optional[CExp]):
        self.name = name
        self.init = init


class CBlockItem(AST):
    """
    block_item = S(statement)
               | D(declaration)
    """
    _fields = ()


class CS(CBlockItem):
    """ S(statement) """
    statement: CStatement = None
    _fields = ('statement',)

    def __init__(self, statement: CStatement):
        self.statement = statement


class CD(CBlockItem):
    """ D(declaration) """
    declaration: CDeclaration = None
    _fields = ('declaration',)

    def __init__(self, declaration: CDeclaration):
        self.declaration = declaration


class CFunctionDef(AST):
    """
    function_definition = Function(identifier, block_item*)
    """
    _fields = ()


class CFunction(CFunctionDef):
    """ Function(identifier name, block_item* body) """
    name: TIdentifier = None
    body: List[CBlockItem] = None
    _fields = ('name', 'body')

    def __init__(self, name: TIdentifier, body: List[CBlockItem]):
        self.name = name
        self.body = body


class CProgram(AST):
    """ AST = Program(function_definition) """
    function_def: CFunctionDef = None
    _fields = ('function_def',)

    def __init__(self, function_def: CFunctionDef):
        self.function_def = function_def
