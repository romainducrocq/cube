from ccc.parser_c_ast cimport AST, TIdentifier, TInt, TLong, StaticInit



cdef class AsmReg(AST):
    # reg = AX
    #     | CX
    #     | DX
    #     | DI
    #     | SI
    #     | R8
    #     | R9
    #     | R10
    #     | R11
    #     | SP
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


cdef class AsmDi(AsmReg):
    # DI
    def __cinit__(self):
        self._fields = ()


cdef class AsmSi(AsmReg):
    # SI
    def __cinit__(self):
        self._fields = ()


cdef class AsmR8(AsmReg):
    # R8
    def __cinit__(self):
        self._fields = ()


cdef class AsmR9(AsmReg):
    # R9
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


cdef class AsmSp(AsmReg):
    # SP
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
    # operand = ImmInt(int)
    #         | ImmLong(long)
    #         | Reg(reg)
    #         | Pseudo(identifier)
    #         | Stack(int)
    #         | AsmData(identifier)
    def __cinit__(self):
        self._fields = ()


cdef class AsmImmInt(AsmOperand):
    # ImmInt(int value)
    def __cinit__(self):
        self._fields = ('value',)

    def __init__(self, TInt value):
        self.value = value


cdef class AsmImmLong(AsmOperand):
    # ImmLong(long value)
    def __cinit__(self):
        self._fields = ('value',)

    def __init__(self, TLong value):
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


cdef class AsmData(AsmOperand):
    # Data(identifier name)
    def __cinit__(self):
        self._fields = ('name',)

    def __init__(self, TIdentifier name):
        self.name = name



cdef class AsmBinaryOp(AST):
    # binary_operator = Add
    #                 | Sub
    #                 | Mult
    #                 | BitAnd
    #                 | BitOr
    #                 | BitXor
    #                 | BitShiftLeft
    #                 | BitShiftRight
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
    # unary_operator = Not
    #                | Neg
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


cdef class AsmAssemblyType(AST):
    # assembly_type = LongWord
    #               | QuadWord
    def __cinit__(self):
        self._fields = ()


cdef class AsmLongWord(AsmAssemblyType):
    # LongWord
    def __cinit__(self):
        self._fields = ()


cdef class AsmQuadWord(AsmAssemblyType):
    # QuadWord
    def __cinit__(self):
        self._fields = ()


cdef class AsmInstruction(AST):
    # instruction = Mov(assembly_type, operand src, operand dst)
    #             | MovSx(operand src, operand dst)
    #             | Unary(unary_operator, assembly_type, operand)
    #             | Binary(binary_operator, assembly_type, operand, operand)
    #             | Cmp(assembly_type, operand, operand)
    #             | Idiv(assembly_type, operand)
    #             | Cdq(assembly_type)
    #             | Jmp(identifier)
    #             | JmpCC(cond_code, identifier)
    #             | SetCC(cond_code, operand)
    #             | Label(identifier)
    #             | AllocateStack(int)
    #             | DeallocateStack(int)
    #             | Push(operand)
    #             | Call(identifier)
    #             | Ret
    def __cinit__(self):
        self._fields = ()


cdef class AsmMov(AsmInstruction):
    # Mov(assembly_type, operand src, operand dst)
    def __cinit__(self):
        self._fields = ('assembly_type', 'src', 'dst')

    def __init__(self, AsmAssemblyType assembly_type, AsmOperand src, AsmOperand dst):
        self.assembly_type = assembly_type
        self.src = src
        self.dst = dst


cdef class AsmMovSx(AsmInstruction):
    # AsmMovSx(operand src, operand dst)
    def __cinit__(self):
        self._fields = ('src', 'dst')

    def __init__(self, AsmOperand src, AsmOperand dst):
        self.src = src
        self.dst = dst


cdef class AsmUnary(AsmInstruction):
    # Unary(unary_operator unop, assembly_type, operand dst)
    def __cinit__(self):
        self._fields = ('unary_op', 'assembly_type', 'dst')

    def __init__(self, AsmUnaryOp unary_op, AsmAssemblyType assembly_type, AsmOperand dst):
        self.unary_op = unary_op
        self.assembly_type = assembly_type
        self.dst = dst


cdef class AsmBinary(AsmInstruction):
    # Binary(binary_operator binop, assembly_type, operand src, operand dst)
    def __cinit__(self):
        self._fields = ('binary_op', 'assembly_type', 'src', 'dst')

    def __init__(self, AsmBinaryOp binary_op, AsmAssemblyType assembly_type, AsmOperand src, AsmOperand dst):
        self.binary_op = binary_op
        self.assembly_type = assembly_type
        self.src = src
        self.dst = dst


cdef class AsmCmp(AsmInstruction):
    # Cmp(assembly_type, operand src, operand dst)
    def __cinit__(self):
        self._fields = ('assembly_type', 'src', 'dst')

    def __init__(self, AsmAssemblyType assembly_type, AsmOperand src, AsmOperand dst):
        self.assembly_type = assembly_type
        self.src = src
        self.dst = dst


cdef class AsmIdiv(AsmInstruction):
    # Idiv(assembly_type, operand src)
    def __cinit__(self):
        self._fields = ('assembly_type', 'src')

    def __init__(self, AsmAssemblyType assembly_type, AsmOperand src):
        self.assembly_type = assembly_type
        self.src = src


cdef class AsmCdq(AsmInstruction):
    # Cdq(assembly_type)
    def __cinit__(self):
        self._fields = ('assembly_type',)

    def __init__(self, AsmAssemblyType assembly_type):
        self.assembly_type = assembly_type


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


cdef class AsmPush(AsmInstruction):
    # Push(operand src)
    def __cinit__(self):
        self._fields = ('src',)

    def __init__(self, AsmOperand src):
        self.src = src


cdef class AsmCall(AsmInstruction):
    # Call(identifier name)
    def __cinit__(self):
        self._fields = ('name',)

    def __init__(self, TIdentifier name):
        self.name = name


cdef class AsmRet(AsmInstruction):
    # Ret
    def __cinit__(self):
        self._fields = ()


cdef class AsmTopLevel(AST):
    # top_level = Function(identifier name, bool global, instruction* instructions)
    #           | StaticVariable(identifier, bool global, int init)
    def __cinit__(self):
        self._fields = ()


cdef class AsmFunction(AsmTopLevel):
    # Function(identifier name, bool global, instruction* instructions)
    def __cinit__(self):
        self._fields = ('name', 'is_global', 'instructions')

    def __init__(self, TIdentifier name, bint is_global, list[AsmInstruction] instructions):
        self.name = name
        self.is_global = is_global
        self.instructions = instructions


cdef class AsmStaticVariable(AsmTopLevel):
    # StaticVariable(identifier, bool global, int alignment, static_init init)
    def __cinit__(self):
        self._fields = ('name', 'is_global', 'alignment', 'initial_value')

    def __init__(self, TIdentifier name, bint is_global, TInt alignment, StaticInit initial_value):
        self.name = name
        self.is_global = is_global
        self.alignment = alignment
        self.initial_value = initial_value


cdef class AsmProgram(AST):
    # AST = Program(top_levels*)
    def __cinit__(self):
        self._fields = ('top_levels',)

    def __init__(self, list[AsmTopLevel] top_levels):
        self.top_levels = top_levels
