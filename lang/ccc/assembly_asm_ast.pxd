from ccc.parser_c_ast cimport AST, TIdentifier, TInt, StaticInit

from ccc.assembly_backend_symbol_table cimport AssemblyType


cdef class AsmReg(AST):
    pass


cdef class AsmAx(AsmReg):
    pass


cdef class AsmCx(AsmReg):
    pass


cdef class AsmDx(AsmReg):
    pass


cdef class AsmDi(AsmReg):
    pass


cdef class AsmSi(AsmReg):
    pass


cdef class AsmR8(AsmReg):
    pass


cdef class AsmR9(AsmReg):
    pass


cdef class AsmR10(AsmReg):
    pass


cdef class AsmR11(AsmReg):
    pass


cdef class AsmSp(AsmReg):
    pass


cdef class AsmXMM0(AsmReg):
    pass


cdef class AsmXMM1(AsmReg):
    pass


cdef class AsmXMM2(AsmReg):
    pass


cdef class AsmXMM3(AsmReg):
    pass


cdef class AsmXMM4(AsmReg):
    pass


cdef class AsmXMM5(AsmReg):
    pass


cdef class AsmXMM6(AsmReg):
    pass


cdef class AsmXMM7(AsmReg):
    pass


cdef class AsmXMM14(AsmReg):
    pass


cdef class AsmXMM15(AsmReg):
    pass


cdef class AsmCondCode(AST):
    pass


cdef class AsmE(AsmCondCode):
    pass


cdef class AsmNE(AsmCondCode):
    pass


cdef class AsmG(AsmCondCode):
    pass


cdef class AsmGE(AsmCondCode):
    pass


cdef class AsmL(AsmCondCode):
    pass


cdef class AsmLE(AsmCondCode):
    pass


cdef class AsmA(AsmCondCode):
    pass


cdef class AsmAE(AsmCondCode):
    pass


cdef class AsmB(AsmCondCode):
    pass


cdef class AsmBE(AsmCondCode):
    pass


cdef class AsmOperand(AST):
    pass


cdef class AsmImm(AsmOperand):
    cdef public TIdentifier value


cdef class AsmRegister(AsmOperand):
    cdef public AsmReg reg


cdef class AsmPseudo(AsmOperand):
    cdef public TIdentifier name


cdef class AsmStack(AsmOperand):
    cdef public TInt value


cdef class AsmData(AsmOperand):
    cdef public TIdentifier name


cdef class AsmBinaryOp(AST):
    pass


cdef class AsmAdd(AsmBinaryOp):
    pass


cdef class AsmSub(AsmBinaryOp):
    pass


cdef class AsmMult(AsmBinaryOp):
    pass


cdef class AsmDivDouble(AsmBinaryOp):
    pass


cdef class AsmBitAnd(AsmBinaryOp):
    pass


cdef class AsmBitOr(AsmBinaryOp):
    pass


cdef class AsmBitXor(AsmBinaryOp):
    pass


cdef class AsmBitShiftLeft(AsmBinaryOp):
    pass


cdef class AsmBitShiftRight(AsmBinaryOp):
    pass


cdef class AsmUnaryOp(AST):
    pass


cdef class AsmNot(AsmUnaryOp):
    pass


cdef class AsmNeg(AsmUnaryOp):
    pass


cdef class AsmShr(AsmUnaryOp):
    pass


cdef class AsmInstruction(AST):
    pass


cdef class AsmMov(AsmInstruction):
    cdef public AssemblyType assembly_type
    cdef public AsmOperand src
    cdef public AsmOperand dst


cdef class AsmMovSx(AsmInstruction):
    cdef public AsmOperand src
    cdef public AsmOperand dst


cdef class AsmMovZeroExtend(AsmInstruction):
    cdef public AsmOperand src
    cdef public AsmOperand dst


cdef class AsmCvttsd2si(AsmInstruction):
    cdef public AssemblyType assembly_type
    cdef public AsmOperand src
    cdef public AsmOperand dst


cdef class AsmCvtsi2sd(AsmInstruction):
    cdef public AssemblyType assembly_type
    cdef public AsmOperand src
    cdef public AsmOperand dst


cdef class AsmUnary(AsmInstruction):
    cdef public AsmUnaryOp unary_op
    cdef public AssemblyType assembly_type
    cdef public AsmOperand dst


cdef class AsmBinary(AsmInstruction):
    cdef public AsmBinaryOp binary_op
    cdef public AssemblyType assembly_type
    cdef public AsmOperand src
    cdef public AsmOperand dst


cdef class AsmCmp(AsmInstruction):
    cdef public AssemblyType assembly_type
    cdef public AsmOperand src
    cdef public AsmOperand dst


cdef class AsmIdiv(AsmInstruction):
    cdef public AssemblyType assembly_type
    cdef public AsmOperand src


cdef class AsmDiv(AsmInstruction):
    cdef public AssemblyType assembly_type
    cdef public AsmOperand src


cdef class AsmCdq(AsmInstruction):
    cdef public AssemblyType assembly_type


cdef class AsmJmp(AsmInstruction):
    cdef public TIdentifier target


cdef class AsmJmpCC(AsmInstruction):
    cdef public AsmCondCode cond_code
    cdef public TIdentifier target


cdef class AsmSetCC(AsmInstruction):
    cdef public AsmCondCode cond_code
    cdef public AsmOperand dst


cdef class AsmLabel(AsmInstruction):
    cdef public TIdentifier name


cdef class AsmPush(AsmInstruction):
    cdef public AsmOperand src


cdef class AsmCall(AsmInstruction):
    cdef public TIdentifier name


cdef class AsmRet(AsmInstruction):
    pass


cdef class AsmTopLevel(AST):
    pass


cdef class AsmFunction(AsmTopLevel):
    cdef public TIdentifier name
    cdef public bint is_global
    cdef public list[AsmInstruction] instructions


cdef class AsmStaticVariable(AsmTopLevel):
    cdef public TIdentifier name
    cdef public bint is_global
    cdef public TInt alignment
    cdef public StaticInit initial_value


cdef class AsmStaticConstant(AsmTopLevel):
    cdef public TIdentifier name
    cdef public TInt alignment
    cdef public StaticInit initial_value


cdef class AsmProgram(AST):
    cdef public list[AsmTopLevel] top_levels
