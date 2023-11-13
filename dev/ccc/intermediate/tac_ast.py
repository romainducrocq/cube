from typing import List

from ccc.util.__ast import *

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
    _fields = ()


class TacComplement(TacUnaryOp):
    """ Complement """
    _fields = ()


class TacNegate(TacUnaryOp):
    """ Negate """
    _fields = ()


class TacNot(TacUnaryOp):
    """ Not """
    _fields = ()


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
    _fields = ()


class TacAdd(TacBinaryOp):
    """ Add """
    _fields = ()


class TacSubtract(TacBinaryOp):
    """ Subtract """
    _fields = ()


class TacMultiply(TacBinaryOp):
    """ Multiply """
    _fields = ()


class TacDivide(TacBinaryOp):
    """ Divide """
    _fields = ()


class TacRemainder(TacBinaryOp):
    """ Remainder """
    _fields = ()


class TacBitAnd(TacBinaryOp):
    """ BitAnd """
    _fields = ()


class TacBitOr(TacBinaryOp):
    """ BitOr """
    _fields = ()


class TacBitXor(TacBinaryOp):
    """ BitXor """
    _fields = ()


class TacBitShiftLeft(TacBinaryOp):
    """ BitShiftLeft """
    _fields = ()


class TacBitShiftRight(TacBinaryOp):
    """ BitShiftRight """
    _fields = ()


class TacEqual(TacBinaryOp):
    """ Equal """
    _fields = ()


class TacNotEqual(TacBinaryOp):
    """ NotEqual """
    _fields = ()


class TacLessThan(TacBinaryOp):
    """ LessThan """
    _fields = ()


class TacLessOrEqual(TacBinaryOp):
    """ LessOrEqual """
    _fields = ()


class TacGreaterThan(TacBinaryOp):
    """ GreaterThan """
    _fields = ()


class TacGreaterOrEqual(TacBinaryOp):
    """ GreaterOrEqual """
    _fields = ()


class TacValue(AST):
    """
    val = Constant(int)
        | Var(identifier)
    """
    _fields = ()


class TacConstant(TacValue):
    """ Constant(int) """
    value: TInt = None
    _fields = ('value',)

    def __init__(self, value: TInt):
        self.value = value


class TacVariable(TacValue):
    """ Var(identifier) """
    name: TIdentifier = None
    _fields = ('name',)

    def __init__(self, name: TIdentifier):
        self.name = name


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
    _fields = ()


class TacReturn(TacInstruction):
    """ Return(val) """
    val: TacValue = None
    _fields = ('val',)

    def __init__(self, val: TacValue):
        self.val = val


class TacUnary(TacInstruction):
    """ Unary(unary_operator, val src, val dst) """
    unary_op: TacUnaryOp = None
    src: TacValue = None
    dst: TacValue = None
    _fields = ('unary_op', 'src', 'dst')

    def __init__(self, unary_op: TacUnaryOp, src: TacValue, dst: TacValue):
        self.unary_op = unary_op
        self.src = src
        self.dst = dst


class TacBinary(TacInstruction):
    """ Binary(binary_operator, val src1, val src2, val dst) """
    binary_op: TacBinaryOp = None
    src1: TacValue = None
    src2: TacValue = None
    dst: TacValue = None
    _fields = ('binary_op', 'src1', 'src2', 'dst')

    def __init__(self, binary_op: TacBinaryOp, src1: TacValue, src2: TacValue, dst: TacValue):
        self.binary_op = binary_op
        self.src1 = src1
        self.src2 = src2
        self.dst = dst


class TacCopy(TacInstruction):
    """ Copy(val src, val dst) """
    src: TacValue = None
    dst: TacValue = None
    _fields = ('src', 'dst')

    def __init__(self, src: TacValue, dst: TacValue):
        self.src = src
        self.dst = dst


class TacJump(TacInstruction):
    """ Jump(identifier target) """
    target: TIdentifier = None
    _fields = ('target',)

    def __init__(self, target: TIdentifier):
        self.target = target


class TacJumpIfZero(TacInstruction):
    """ JumpIfZero(val condition, identifier target) """
    condition: TacValue = None
    target: TIdentifier = None
    _fields = ('condition', 'target')

    def __init__(self, condition: TacValue, target: TIdentifier):
        self.condition = condition
        self.target = target


class TacJumpIfNotZero(TacInstruction):
    """ JumpIfNotZero(val condition, identifier target) """
    condition: TacValue = None
    target: TIdentifier = None
    _fields = ('condition', 'target')

    def __init__(self, condition: TacValue, target: TIdentifier):
        self.condition = condition
        self.target = target


class TacLabel(TacInstruction):
    """ Label(identifier name) """
    name: TIdentifier = None
    _fields = ('name',)

    def __init__(self, name: TIdentifier):
        self.name = name


class TacFunctionDef(AST):
    """
    function_definition = Function(identifier, instruction* body)
    """
    _fields = ()


class TacFunction(TacFunctionDef):
    """ Function(identifier, instruction* body) """
    name: TIdentifier = None
    body: List[TacInstruction] = None
    _fields = ('name', 'body')

    def __init__(self, name: TIdentifier, body: List[TacInstruction]):
        self.name = name
        self.body = body


class TacProgram(AST):
    """ AST = Program(function_definition) """
    function_def: TacFunctionDef = None
    _fields = ('function_def',)

    def __init__(self, function_def: TacFunctionDef):
        self.function_def = function_def
