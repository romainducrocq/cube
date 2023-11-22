from ccc.intermediate_tac_ast cimport AST, TIdentifier, TInt


cdef class AsmReg(AST):
    # 
    # reg = AX
    #     | CX
    #     | DX
    #     | R10
    #     | R11
    # 
    def __cinit__(self):
        self._fields = ()


cdef class AsmAx(AsmReg):
    # AX
    def __cinit__(self):
        self._fields = ()


cdef class AsmCx(AsmReg):
    # CX
    def __cinit__(self):
        self._fields = ()


cdef class AsmDx(AsmReg):
    # DX
    def __cinit__(self):
        self._fields = ()


cdef class AsmR10(AsmReg):
    # R10
    def __cinit__(self):
        self._fields = ()


cdef class AsmR11(AsmReg):
    # R11
    def __cinit__(self):
        self._fields = ()


cdef class AsmCondCode(AST):
    # 
    # cond_code = E
    #           | NE
    #           | G
    #           | GE
    #           | L
    #           | LE
    # 
    def __cinit__(self):
        self._fields = ()


cdef class AsmE(AsmCondCode):
    # E
    def __cinit__(self):
        self._fields = ()


cdef class AsmNE(AsmCondCode):
    # NE
    def __cinit__(self):
        self._fields = ()


cdef class AsmG(AsmCondCode):
    # G
    def __cinit__(self):
        self._fields = ()


cdef class AsmGE(AsmCondCode):
    # GE
    def __cinit__(self):
        self._fields = ()


cdef class AsmL(AsmCondCode):
    # L
    def __cinit__(self):
        self._fields = ()


cdef class AsmLE(AsmCondCode):
    # LE
    def __cinit__(self):
        self._fields = ()


cdef class AsmOperand(AST):
    # 
    # operand = Imm(int)
    #         | Reg(reg)
    #         | Pseudo(identifier)
    #         | Stack(int)
    # 
    def __cinit__(self):
        self._fields = ()


cdef class AsmImm(AsmOperand):
    # Imm(int value)
    def __cinit__(self):
        self._fields = ('value',)

    def __init__(self, TInt value):
        self.value = value


cdef class AsmRegister(AsmOperand):
    # Register(reg reg)
    def __cinit__(self):
        self._fields = ('reg',)

    def __init__(self, AsmReg reg):
        self.reg = reg


cdef class AsmPseudo(AsmOperand):
    # Pseudo(identifier name)
    def __cinit__(self):
        self._fields = ('name',)

    def __init__(self, TIdentifier name):
        self.name = name


cdef class AsmStack(AsmOperand):
    # Stack(int value)
    def __cinit__(self):
        self._fields = ('value',)

    def __init__(self, TInt value):
        self.value = value


cdef class AsmBinaryOp(AST):
    # 
    # binary_operator = Add
    #                 | Sub
    #                 | Mult
    #                 | BitAnd
    #                 | BitOr
    #                 | BitXor
    #                 | BitShiftLeft
    #                 | BitShiftRight
    # 
    def __cinit__(self):
        self._fields = ()


cdef class AsmAdd(AsmBinaryOp):
    # Add
    def __cinit__(self):
        self._fields = ()


cdef class AsmSub(AsmBinaryOp):
    # Sub
    def __cinit__(self):
        self._fields = ()


cdef class AsmMult(AsmBinaryOp):
    # Mult
    def __cinit__(self):
        self._fields = ()


cdef class AsmBitAnd(AsmBinaryOp):
    # BitAnd
    def __cinit__(self):
        self._fields = ()


cdef class AsmBitOr(AsmBinaryOp):
    # BitOr
    def __cinit__(self):
        self._fields = ()


cdef class AsmBitXor(AsmBinaryOp):
    # BitXor
    def __cinit__(self):
        self._fields = ()


cdef class AsmBitShiftLeft(AsmBinaryOp):
    # BitShiftLeft
    def __cinit__(self):
        self._fields = ()


cdef class AsmBitShiftRight(AsmBinaryOp):
    # BitShiftRight
    def __cinit__(self):
        self._fields = ()


cdef class AsmUnaryOp(AST):
    # 
    # unary_operator = Not
    #                | Neg
    # 
    def __cinit__(self):
        self._fields = ()


cdef class AsmNot(AsmUnaryOp):
    # Not
    def __cinit__(self):
        self._fields = ()


cdef class AsmNeg(AsmUnaryOp):
    # Neg
    def __cinit__(self):
        self._fields = ()


cdef class AsmInstruction(AST):
    # 
    # instruction = Mov(operand src, operand dst)
    #             | Unary(unary_operator, operand)
    #             | Binary(binary_operator, operand, operand)
    #             | Cmp(operand, operand)
    #             | Idiv(operand)
    #             | Cdq
    #             | Jmp(identifier)
    #             | JmpCC(cond_code, identifier)
    #             | SetCC(cond_code, operand)
    #             | Label(identifier)
    #             | AllocateStack(int)
    #             | Ret
    # 
    def __cinit__(self):
        self._fields = ()


cdef class AsmMov(AsmInstruction):
    # Mov(operand src, operand dst)
    def __cinit__(self):
        self._fields = ('src', 'dst')

    def __init__(self, AsmOperand src, AsmOperand dst):
        self.src = src
        self.dst = dst


cdef class AsmUnary(AsmInstruction):
    # Unary(unary_operator unop, operand dst)
    def __cinit__(self):
        self._fields = ('unary_op', 'dst')

    def __init__(self, AsmUnaryOp unary_op, AsmOperand dst):
        self.unary_op = unary_op
        self.dst = dst


cdef class AsmBinary(AsmInstruction):
    # Binary(binary_operator binop, operand src, operand dst)
    def __cinit__(self):
        self._fields = ('binary_op', 'src', 'dst')

    def __init__(self, AsmBinaryOp binary_op, AsmOperand src, AsmOperand dst):
        self.binary_op = binary_op
        self.src = src
        self.dst = dst


cdef class AsmCmp(AsmInstruction):
    # Cmp(operand src, operand dst)
    def __cinit__(self):
        self._fields = ('src', 'dst')

    def __init__(self, AsmOperand src, AsmOperand dst):
        self.src = src
        self.dst = dst


cdef class AsmIdiv(AsmInstruction):
    # Idiv(operand src)
    def __cinit__(self):
        self._fields = ('src',)

    def __init__(self, AsmOperand src):
        self.src = src


cdef class AsmCdq(AsmInstruction):
    # Cdq
    def __cinit__(self):
        self._fields = ()


cdef class AsmJmp(AsmInstruction):
    # Jmp(identifier target)
    def __cinit__(self):
        self._fields = ('target',)

    def __init__(self, TIdentifier target):
        self.target = target


cdef class AsmJmpCC(AsmInstruction):
    # JmpCC(cond_code cond_code, identifier target)
    def __cinit__(self):
        self._fields = ('cond_code', 'target')

    def __init__(self, AsmCondCode cond_code, TIdentifier target):
        self.cond_code = cond_code
        self.target = target


cdef class AsmSetCC(AsmInstruction):
    # SetCC(cond_code cond_code, operand dst)
    def __cinit__(self):
        self._fields = ('cond_code', 'dst')

    def __init__(self, AsmCondCode cond_code, AsmOperand dst):
        self.cond_code = cond_code
        self.dst = dst


cdef class AsmLabel(AsmInstruction):
    # Label(identifier name)
    def __cinit__(self):
        self._fields = ('name',)

    def __init__(self, TIdentifier name):
        self.name = name


cdef class AsmAllocStack(AsmInstruction):
    # AllocateStack(int value)
    def __cinit__(self):
        self._fields = ('value',)

    def __init__(self, TInt value):
        self.value = value


cdef class AsmRet(AsmInstruction):
    # Ret
    def __cinit__(self):
        self._fields = ()


cdef class AsmFunctionDef(AST):
    # 
    # function_definition = Function(identifier name, instruction* instructions)
    # 
    def __cinit__(self):
        self._fields = ()


cdef class AsmFunction(AsmFunctionDef):
    # Function(identifier name, instruction* instructions)
    def __cinit__(self):
        self._fields = ('name', 'instructions')

    def __init__(self, TIdentifier name, list[AsmInstruction] instructions):
        self.name = name
        self.instructions = instructions


cdef class AsmProgram(AST):
    # AST = Program(function_definition)
    def __cinit__(self):
        self._fields = ('function_def',)

    def __init__(self, AsmFunctionDef function_def):
        self.function_def = function_def
