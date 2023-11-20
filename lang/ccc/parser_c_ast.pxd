from ccc.util_ast cimport AST, TIdentifier, TInt


cdef class CUnaryOp(AST):
    pass

cdef class CComplement(CUnaryOp):
    pass

cdef class CNegate(CUnaryOp):
    pass

cdef class CNot(CUnaryOp):
    pass


cdef class CBinaryOp(AST):
    pass


cdef class CAdd(CBinaryOp):
    pass


cdef class CSubtract(CBinaryOp):
    pass


cdef class CMultiply(CBinaryOp):
    pass


cdef class CDivide(CBinaryOp):
    pass


cdef class CRemainder(CBinaryOp):
    pass


cdef class CBitAnd(CBinaryOp):
    pass


cdef class CBitOr(CBinaryOp):
    pass


cdef class CBitXor(CBinaryOp):
    pass


cdef class CBitShiftLeft(CBinaryOp):
    pass


cdef class CBitShiftRight(CBinaryOp):
    pass


cdef class CAnd(CBinaryOp):
    pass


cdef class COr(CBinaryOp):
    pass


cdef class CEqual(CBinaryOp):
    pass


cdef class CNotEqual(CBinaryOp):
    pass


cdef class CLessThan(CBinaryOp):
    pass


cdef class CLessOrEqual(CBinaryOp):
    pass


cdef class CGreaterThan(CBinaryOp):
    pass


cdef class CGreaterOrEqual(CBinaryOp):
    pass


cdef class CExp(AST):
    pass


cdef class CConstant(CExp):
    cdef public TInt value


cdef class CVar(CExp):
    cdef public TIdentifier name


cdef class CUnary(CExp):
    cdef public CUnaryOp unary_op
    cdef public CExp exp


cdef class CBinary(CExp):
    cdef public CBinaryOp binary_op
    cdef public CExp exp_left
    cdef public CExp exp_right


cdef class CAssignment(CExp):
    cdef public CExp exp_left
    cdef public CExp exp_right


cdef class CAssignmentCompound(CExp):
    cdef public CBinaryOp binary_op
    cdef public CExp exp_left
    cdef public CExp exp_right


cdef class CStatement(AST):
    pass


cdef class CReturn(CStatement):
    cdef public CExp exp


cdef class CExpression(CStatement):
    cdef public CExp exp


cdef class CNull(CStatement):
    pass


cdef class CDeclaration(AST):
    pass


cdef class CDecl(CDeclaration):
    cdef public TIdentifier name
    # Optional
    cdef public CExp init


cdef class CBlockItem(AST):
    pass


cdef class CS(CBlockItem):
    cdef public CStatement statement


cdef class CD(CBlockItem):
    cdef public CDeclaration declaration


cdef class CFunctionDef(AST):
    pass


cdef class CFunction(CFunctionDef):
    cdef public TIdentifier name
    cdef public list[CBlockItem] body


cdef class CProgram(AST):
    cdef public CFunctionDef function_def
