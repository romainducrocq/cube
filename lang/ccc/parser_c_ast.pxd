from ccc.abc_builtin_ast cimport AST, TIdentifier
from ccc.semantic_symbol_table cimport *


cdef class CConst(AST):
    pass


cdef class CConstInt(CConst):
    cdef public TInt value


cdef class CConstLong(CConst):
    cdef public TLong value


cdef class CConstUInt(CConst):
    cdef public TUInt value


cdef class CConstULong(CConst):
    cdef public TULong value


cdef class CConstDouble(CConst):
    cdef public TDouble value


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
    cdef public Type exp_type


cdef class CConstant(CExp):
    cdef public CConst constant


cdef class CVar(CExp):
    cdef public TIdentifier name


cdef class CCast(CExp):
    cdef public CExp exp
    cdef public Type target_type


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


cdef class CConditional(CExp):
    cdef public CExp condition
    cdef public CExp exp_middle
    cdef public CExp exp_right


cdef class CFunctionCall(CExp):
    cdef public TIdentifier name
    cdef public list[CExp] args


cdef class CStatement(AST):
    pass


cdef class CReturn(CStatement):
    cdef public CExp exp


cdef class CExpression(CStatement):
    cdef public CExp exp


cdef class CIf(CStatement):
    cdef public CExp condition
    cdef public CStatement then
    # Optional
    cdef public CStatement else_fi


cdef class CGoto(CStatement):
    cdef public TIdentifier target


cdef class CLabel(CStatement):
    cdef public TIdentifier target
    cdef public CStatement jump_to


cdef class CCompound(CStatement):
    cdef public CBlock block


cdef class CWhile(CStatement):
    cdef public CExp condition
    cdef public CStatement body
    cdef public TIdentifier target


cdef class CDoWhile(CStatement):
    cdef public CExp condition
    cdef public CStatement body
    cdef public TIdentifier target


cdef class CFor(CStatement):
    cdef public CForInit init
    # Optional
    cdef public CExp condition
    # Optional
    cdef public CExp post
    cdef public CStatement body
    cdef public TIdentifier target


cdef class CBreak(CStatement):
    cdef public TIdentifier target


cdef class CContinue(CStatement):
    cdef public TIdentifier target


cdef class CNull(CStatement):
    pass


cdef class CForInit(AST):
    pass


cdef class CInitDecl(CForInit):
    cdef public CVariableDeclaration init


cdef class CInitExp(CForInit):
    # Optional
    cdef public CExp init


cdef class CBlock(AST):
    pass


cdef class CB(CBlock):
    cdef public list[CBlockItem] block_items


cdef class CBlockItem(AST):
    pass


cdef class CS(CBlockItem):
    cdef public CStatement statement


cdef class CD(CBlockItem):
    cdef public CDeclaration declaration


cdef class CStorageClass(AST):
    pass


cdef class CStatic(CStorageClass):
    pass


cdef class CExtern(CStorageClass):
    pass


cdef class CFunctionDeclaration(AST):
    cdef public TIdentifier name
    cdef public list[TIdentifier] params
    # Optional
    cdef public CBlock body
    cdef public Type fun_type
    # Optional
    cdef public CStorageClass storage_class


cdef class CVariableDeclaration(AST):
    cdef public TIdentifier name
    # Optional
    cdef public CExp init
    cdef public Type var_type
    # Optional
    cdef public CStorageClass storage_class


cdef class CDeclaration(AST):
    pass


cdef class CFunDecl(CDeclaration):
    cdef public CFunctionDeclaration function_decl


cdef class CVarDecl(CDeclaration):
    cdef public CVariableDeclaration variable_decl


cdef class CProgram(AST):
    cdef public list[CDeclaration] declarations
