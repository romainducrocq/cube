from ccc.parser_c_ast cimport AST, TIdentifier, CConst, Type, StaticInit


cdef class TacUnaryOp(AST):
    # unary_operator = Complement
    #                | Negate
    #                | Not
    def __cinit__(self):
        self._fields = ()


cdef class TacComplement(TacUnaryOp):
    # Complement
    def __cinit__(self):
        self._fields = ()


cdef class TacNegate(TacUnaryOp):
    # Negate
    def __cinit__(self):
        self._fields = ()


cdef class TacNot(TacUnaryOp):
    # Not
    def __cinit__(self):
        self._fields = ()


cdef class TacBinaryOp(AST):
    # binary_operator = Add
    #                 | Subtract
    #                 | Multiply
    #                 | Divide
    #                 | Remainder
    #                 | BitAnd
    #                 | BitOr
    #                 | BitXor
    #                 | BitShiftLeft
    #                 | BitShiftRight
    #                 | Equal
    #                 | NotEqual
    #                 | LessThan
    #                 | LessOrEqual
    #                 | GreaterThan
    #                 | GreaterOrEqual
    def __cinit__(self):
        self._fields = ()


cdef class TacAdd(TacBinaryOp):
    # Add
    def __cinit__(self):
        self._fields = ()


cdef class TacSubtract(TacBinaryOp):
    # Subtract
    def __cinit__(self):
        self._fields = ()


cdef class TacMultiply(TacBinaryOp):
    # Multiply
    def __cinit__(self):
        self._fields = ()


cdef class TacDivide(TacBinaryOp):
    # Divide
    def __cinit__(self):
        self._fields = ()


cdef class TacRemainder(TacBinaryOp):
    # Remainder
    def __cinit__(self):
        self._fields = ()


cdef class TacBitAnd(TacBinaryOp):
    # BitAnd
    def __cinit__(self):
        self._fields = ()


cdef class TacBitOr(TacBinaryOp):
    # BitOr
    def __cinit__(self):
        self._fields = ()


cdef class TacBitXor(TacBinaryOp):
    # BitXor
    def __cinit__(self):
        self._fields = ()


cdef class TacBitShiftLeft(TacBinaryOp):
    # BitShiftLeft
    def __cinit__(self):
        self._fields = ()


cdef class TacBitShiftRight(TacBinaryOp):
    # BitShiftRight
    def __cinit__(self):
        self._fields = ()


cdef class TacEqual(TacBinaryOp):
    # Equal
    def __cinit__(self):
        self._fields = ()


cdef class TacNotEqual(TacBinaryOp):
    # NotEqual
    def __cinit__(self):
        self._fields = ()


cdef class TacLessThan(TacBinaryOp):
    # LessThan
    def __cinit__(self):
        self._fields = ()


cdef class TacLessOrEqual(TacBinaryOp):
    # LessOrEqual
    def __cinit__(self):
        self._fields = ()


cdef class TacGreaterThan(TacBinaryOp):
    # GreaterThan
    def __cinit__(self):
        self._fields = ()


cdef class TacGreaterOrEqual(TacBinaryOp):
    # GreaterOrEqual
    def __cinit__(self):
        self._fields = ()


cdef class TacValue(AST):
    # val = Constant(int)
    #     | Var(identifier)
    def __cinit__(self):
        self._fields = ()


cdef class TacConstant(TacValue):
    # Constant(int)
    def __cinit__(self):
        self._fields = ('constant',)

    def __init__(self, CConst constant):
        self.constant = constant


cdef class TacVariable(TacValue):
    # Var(identifier)
    def __cinit__(self):
        self._fields = ('name',)

    def __init__(self, TIdentifier name):
        self.name = name


cdef class TacInstruction(AST):
    # instruction = Return(val)
    #             | SignExtend(val src, val dst)
    #             | Truncate(val src, val dst)
    #             | ZeroExtend(val src, val dst)
    #             | FunCall(identifier fun_name, val* args, val dst)
    #             | Unary(unary_operator, val src, val dst)
    #             | Binary(binary_operator, val src1, val src2, val dst)
    #             | Copy(val src, val dst)
    #             | Jump(identifier target)
    #             | JumpIfZero(val condition, identifier target)
    #             | JumpIfNotZero(val condition, identifier target)
    #             | Label(identifier name)
    def __cinit__(self):
        self._fields = ()


cdef class TacReturn(TacInstruction):
    # Return(val)
    def __cinit__(self):
        self._fields = ('val',)

    def __init__(self, TacValue val):
        self.val = val


cdef class TacSignExtend(TacInstruction):
    # SignExtend(val src, val dst)
    def __cinit__(self):
        self._fields = ('src', 'dst')

    def __init__(self, TacValue src, TacValue dst):
        self.src = src
        self.dst = dst


cdef class TacTruncate(TacInstruction):
    # Truncate(val src, val dst)
    def __cinit__(self):
        self._fields = ('src', 'dst')

    def __init__(self, TacValue src, TacValue dst):
        self.src = src
        self.dst = dst


cdef class TacZeroExtend(TacInstruction):
    # ZeroExtend(val src, val dst)
    def __cinit__(self):
        self._fields = ('src', 'dst')

    def __init__(self, TacValue src, TacValue dst):
        self.src = src
        self.dst = dst


cdef class TacFunCall(TacInstruction):
    # FunCall(identifier fun_name, val* args, val dst)
    def __cinit__(self):
        self._fields = ('name', 'args', 'dst')

    def __init__(self, TIdentifier name, list[TacValue] args, TacValue dst):
        self.name = name
        self.args = args
        self.dst = dst


cdef class TacUnary(TacInstruction):
    # Unary(unary_operator, val src, val dst)
    def __cinit__(self):
        self._fields = ('unary_op', 'src', 'dst')

    def __init__(self, TacUnaryOp unary_op, TacValue src, TacValue dst):
        self.unary_op = unary_op
        self.src = src
        self.dst = dst


cdef class TacBinary(TacInstruction):
    # Binary(binary_operator, val src1, val src2, val dst)
    def __cinit__(self):
        self._fields = ('binary_op', 'src1', 'src2', 'dst')

    def __init__(self, TacBinaryOp binary_op, TacValue src1, TacValue src2, TacValue dst):
        self.binary_op = binary_op
        self.src1 = src1
        self.src2 = src2
        self.dst = dst


cdef class TacCopy(TacInstruction):
    # Copy(val src, val dst)
    def __cinit__(self):
        self._fields = ('src', 'dst')

    def __init__(self, TacValue src, TacValue dst):
        self.src = src
        self.dst = dst


cdef class TacJump(TacInstruction):
    # Jump(identifier target)
    def __cinit__(self):
        self._fields = ('target',)

    def __init__(self, TIdentifier target):
        self.target = target


cdef class TacJumpIfZero(TacInstruction):
    # JumpIfZero(val condition, identifier target)
    def __cinit__(self):
        self._fields = ('condition', 'target')

    def __init__(self, TacValue condition, TIdentifier target):
        self.condition = condition
        self.target = target


cdef class TacJumpIfNotZero(TacInstruction):
    # JumpIfNotZero(val condition, identifier target)
    def __cinit__(self):
        self._fields = ('condition', 'target')

    def __init__(self, TacValue condition, TIdentifier target):
        self.condition = condition
        self.target = target


cdef class TacLabel(TacInstruction):
    # Label(identifier name)
    def __cinit__(self):
        self._fields = ('name',)

    def __init__(self, TIdentifier name):
        self.name = name


cdef class TacTopLevel(AST):
    #
    # top_level = Function(identifier, bool global, identifier* params, instruction* body)
    #           | StaticVariable(identifier, bool global, type t, static_init init)
    #
    def __cinit__(self):
        self._fields = ()


cdef class TacFunction(TacTopLevel):
    # Function(identifier, bool global, identifier* params, instruction* body)
    def __cinit__(self):
        self._fields = ('name', 'is_global', 'params', 'body')

    def __init__(self, TIdentifier name, bint is_global, list[TIdentifier] params, list[TacInstruction] body):
        self.name = name
        self.is_global = is_global
        self.params = params
        self.body = body


cdef class TacStaticVariable(TacTopLevel):
    # StaticVariable(identifier, bool global, type t, static_init init)
    def __cinit__(self):
        self._fields = ('name', 'is_global', 'static_init_type', 'initial_value')

    def __init__(self, TIdentifier name, bint is_global, Type static_init_type, StaticInit initial_value):
        self.name = name
        self.is_global = is_global
        self.static_init_type = static_init_type
        self.initial_value = initial_value


cdef class TacProgram(AST):
    # AST = Program(top_level*)
    def __cinit__(self):
        self._fields = ('top_levels',)

    def __init__(self, list[TacTopLevel] top_levels):
        self.top_levels = top_levels
