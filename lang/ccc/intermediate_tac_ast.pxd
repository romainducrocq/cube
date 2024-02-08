from ccc.parser_c_ast cimport AST, TIdentifier, CConst, Type, StaticInit


cdef class TacUnaryOp(AST):
    pass


cdef class TacComplement(TacUnaryOp):
    pass


cdef class TacNegate(TacUnaryOp):
    pass


cdef class TacNot(TacUnaryOp):
    pass


cdef class TacBinaryOp(AST):
    pass


cdef class TacAdd(TacBinaryOp):
    pass


cdef class TacSubtract(TacBinaryOp):
    pass


cdef class TacMultiply(TacBinaryOp):
    pass


cdef class TacDivide(TacBinaryOp):
    pass


cdef class TacRemainder(TacBinaryOp):
    pass


cdef class TacBitAnd(TacBinaryOp):
    pass


cdef class TacBitOr(TacBinaryOp):
    pass


cdef class TacBitXor(TacBinaryOp):
    pass


cdef class TacBitShiftLeft(TacBinaryOp):
    pass


cdef class TacBitShiftRight(TacBinaryOp):
    pass


cdef class TacEqual(TacBinaryOp):
    pass


cdef class TacNotEqual(TacBinaryOp):
    pass


cdef class TacLessThan(TacBinaryOp):
    pass


cdef class TacLessOrEqual(TacBinaryOp):
    pass


cdef class TacGreaterThan(TacBinaryOp):
    pass


cdef class TacGreaterOrEqual(TacBinaryOp):
    pass


cdef class TacValue(AST):
    pass


cdef class TacConstant(TacValue):
    cdef public CConst constant


cdef class TacVariable(TacValue):
    cdef public TIdentifier name


cdef class TacInstruction(AST):
    pass


cdef class TacReturn(TacInstruction):
    cdef public TacValue val


cdef class TacSignExtend(TacInstruction):
    cdef public TacValue src
    cdef public TacValue dst


cdef class TacTruncate(TacInstruction):
    cdef public TacValue src
    cdef public TacValue dst


cdef class TacZeroExtend(TacInstruction):
    cdef public TacValue src
    cdef public TacValue dst


cdef class TacDoubleToInt(TacInstruction):
    cdef public TacValue src
    cdef public TacValue dst


cdef class TacDoubleToUInt(TacInstruction):
    cdef public TacValue src
    cdef public TacValue dst


cdef class TacIntToDouble(TacInstruction):
    cdef public TacValue src
    cdef public TacValue dst


cdef class TacUIntToDouble(TacInstruction):
    cdef public TacValue src
    cdef public TacValue dst


cdef class TacFunCall(TacInstruction):
    cdef public TIdentifier name
    cdef public list[TacValue] args
    cdef public TacValue dst


cdef class TacUnary(TacInstruction):
    cdef public TacUnaryOp unary_op
    cdef public TacValue src
    cdef public TacValue dst


cdef class TacBinary(TacInstruction):
    cdef public TacBinaryOp binary_op
    cdef public TacValue src1
    cdef public TacValue src2
    cdef public TacValue dst


cdef class TacCopy(TacInstruction):
    cdef public TacValue src
    cdef public TacValue dst


cdef class TacJump(TacInstruction):
    cdef public TIdentifier target


cdef class TacJumpIfZero(TacInstruction):
    cdef public TacValue condition
    cdef public TIdentifier target


cdef class TacJumpIfNotZero(TacInstruction):
    cdef public TacValue condition
    cdef public TIdentifier target


cdef class TacLabel(TacInstruction):
    cdef public TIdentifier name


cdef class TacTopLevel(AST):
    pass


cdef class TacFunction(TacTopLevel):
    cdef public TIdentifier name
    cdef public bint is_global
    cdef public list[TIdentifier] params
    cdef public list[TacInstruction] body


cdef class TacStaticVariable(TacTopLevel):
    cdef public TIdentifier name
    cdef public bint is_global
    cdef public Type static_init_type
    cdef public StaticInit initial_value


cdef class TacProgram(AST):
    cdef public list[TacTopLevel] static_variable_top_levels
    cdef public list[TacTopLevel] function_top_levels
