from typing import List

from ccc.util.__ast import *

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
    _fields = ()


class AsmAx(AsmReg):
    """ AX """
    _fields = ()


class AsmCx(AsmReg):
    """ CX """
    _fields = ()


class AsmDx(AsmReg):
    """ DX """
    _fields = ()


class AsmR10(AsmReg):
    """ R10 """
    _fields = ()


class AsmR11(AsmReg):
    """ R11 """
    _fields = ()


class AsmCondCode(AST):
    """
    cond_code = E
              | NE
              | G
              | GE
              | L
              | LE
    """
    _fields = ()


class AsmE(AsmCondCode):
    """ E """
    _fields = ()


class AsmNE(AsmCondCode):
    """ NE """
    _fields = ()


class AsmG(AsmCondCode):
    """ G """
    _fields = ()


class AsmGE(AsmCondCode):
    """ GE """
    _fields = ()


class AsmL(AsmCondCode):
    """ L """
    _fields = ()


class AsmLE(AsmCondCode):
    """ LE """
    _fields = ()


class AsmOperand(AST):
    """
    operand = Imm(int)
            | Reg(reg)
            | Pseudo(identifier)
            | Stack(int)
    """
    _fields = ()


class AsmImm(AsmOperand):
    """ Imm(int value) """
    value: TInt = None
    _fields = ('value',)

    def __init__(self, value: TInt):
        self.value = value


class AsmRegister(AsmOperand):
    """ Register(reg register) """
    register: AsmReg = None
    _fields = ('register',)

    def __init__(self, register: AsmReg):
        self.register = register


class AsmPseudo(AsmOperand):
    """ Pseudo(identifier name) """
    name: TIdentifier = None
    _fields = ('name',)

    def __init__(self, name: TIdentifier):
        self.name = name


class AsmStack(AsmOperand):
    """ Stack(int value) """
    value: TInt = None
    _fields = ('value',)

    def __init__(self, value: TInt):
        self.value = value


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
    _fields = ()


class AsmAdd(AsmBinaryOp):
    """ Add """
    _fields = ()


class AsmSub(AsmBinaryOp):
    """ Sub """
    _fields = ()


class AsmMult(AsmBinaryOp):
    """ Mult """
    _fields = ()


class AsmBitAnd(AsmBinaryOp):
    """ BitAnd """
    _fields = ()


class AsmBitOr(AsmBinaryOp):
    """ BitOr """
    _fields = ()


class AsmBitXor(AsmBinaryOp):
    """ BitXor """
    _fields = ()


class AsmBitShiftLeft(AsmBinaryOp):
    """ BitShiftLeft """
    _fields = ()


class AsmBitShiftRight(AsmBinaryOp):
    """ BitShiftRight """
    _fields = ()


class AsmUnaryOp(AST):
    """
    unary_operator = Not
                   | Neg
    """
    _fields = ()


class AsmNot(AsmUnaryOp):
    """ Not """
    _fields = ()


class AsmNeg(AsmUnaryOp):
    """ Neg """
    _fields = ()


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
    _fields = ()


class AsmMov(AsmInstruction):
    """ Mov(operand src, operand dst) """
    src: AsmOperand = None
    dst: AsmOperand = None
    _fields = ('src', 'dst')

    def __init__(self, src: AsmOperand, dst: AsmOperand):
        self.src = src
        self.dst = dst


class AsmUnary(AsmInstruction):
    """ Unary(unary_operator unop, operand dst) """
    unary_op: AsmUnaryOp = None
    dst: AsmOperand = None
    _fields = ('unary_op', 'dst')

    def __init__(self, unary_op: AsmUnaryOp, dst: AsmOperand):
        self.unary_op = unary_op
        self.dst = dst


class AsmBinary(AsmInstruction):
    """ Binary(binary_operator binop, operand src, operand dst) """
    binary_op: AsmBinaryOp = None
    src: AsmOperand = None
    dst: AsmOperand = None
    _fields = ('binary_op', 'src', 'dst')

    def __init__(self, binary_op: AsmBinaryOp, src: AsmOperand, dst: AsmOperand):
        self.binary_op = binary_op
        self.src = src
        self.dst = dst


class AsmCmp(AsmInstruction):
    """ Cmp(operand src, operand dst) """
    src: AsmOperand = None
    dst: AsmOperand = None
    _fields = ('src', 'dst')

    def __init__(self, src: AsmOperand, dst: AsmOperand):
        self.src = src
        self.dst = dst


class AsmIdiv(AsmInstruction):
    """ Idiv(operand src) """
    src: AsmOperand = None
    _fields = ('src',)

    def __init__(self, src: AsmOperand):
        self.src = src


class AsmCdq(AsmInstruction):
    """ Cdq """
    _fields = ()


class AsmJmp(AsmInstruction):
    """ Jmp(identifier target) """
    target: TIdentifier = None
    _fields = ('target',)

    def __init__(self, target: TIdentifier):
        self.target = target


class AsmJmpCC(AsmInstruction):
    """ JmpCC(cond_code cond_code, identifier target) """
    cond_code: AsmCondCode = None
    target: TIdentifier = None
    _fields = ('cond_code', 'target')

    def __init__(self, cond_code: AsmCondCode, target: TIdentifier):
        self.cond_code = cond_code
        self.target = target


class AsmSetCC(AsmInstruction):
    """ SetCC(cond_code cond_code, operand dst) """
    cond_code: AsmCondCode = None
    dst: AsmOperand = None
    _fields = ('cond_code', 'dst')

    def __init__(self, cond_code: AsmCondCode, dst: AsmOperand):
        self.cond_code = cond_code
        self.dst = dst


class AsmLabel(AsmInstruction):
    """ Label(identifier name) """
    name: TIdentifier = None
    _fields = ('name',)

    def __init__(self, name: TIdentifier):
        self.name = name


class AsmAllocStack(AsmInstruction):
    """ AllocateStack(int value) """
    value: TInt = None
    _fields = ('value',)

    def __init__(self, value: TInt):
        self.value = value


class AsmRet(AsmInstruction):
    """ Ret """
    _fields = ()


class AsmFunctionDef(AST):
    """
    function_definition = Function(identifier name, instruction* instructions)
    """
    _fields = ()


class AsmFunction(AsmFunctionDef):
    """ Function(identifier name, instruction* instructions) """
    name: TIdentifier = None
    instructions: List[AsmInstruction] = None
    _fields = ('name', 'instructions')

    def __init__(self, name: TIdentifier, instructions: List[AsmInstruction]):
        self.name = name
        self.instructions = instructions


class AsmProgram(AST):
    """ AST = Program(function_definition) """
    function_def: AsmFunctionDef = None
    _fields = ('function_def',)

    def __init__(self, function_def: AsmFunctionDef):
        self.function_def = function_def
