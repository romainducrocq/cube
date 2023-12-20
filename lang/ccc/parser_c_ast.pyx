from ccc.abc_builtin_ast cimport AST, TIdentifier
from ccc.semantic_symbol_table cimport *


cdef class CConst(AST):
    # const = ConstInt(int)
    #       | ConstLong(long)
    def __cinit__(self):
        self._fields = ()


cdef class CConstInt(CConst):
    # ConstInt(int)
    def __cinit__(self):
        self._fields = ('value',)

    def __init__(self, TInt value):
        self.value = value


cdef class CConstLong(CConst):
    # ConstLong(long)
    def __cinit__(self):
        self._fields = ('value',)

    def __init__(self, TLong value):
        self.value = value


cdef class CUnaryOp(AST):
    # unary_operator = Complement
    #                | Negate
    #                | Not
    def __cinit__(self):
        self._fields = ()


cdef class CComplement(CUnaryOp):
    # Complement
    def __cinit__(self):
        self._fields = ()


cdef class CNegate(CUnaryOp):
    # Negate
    def __cinit__(self):
        self._fields = ()


cdef class CNot(CUnaryOp):
    # Not
    def __cinit__(self):
        self._fields = ()


cdef class CBinaryOp(AST):
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
    #                 | And
    #                 | Or
    #                 | Equal
    #                 | NotEqual
    #                 | LessThan
    #                 | LessOrEqual
    #                 | GreaterThan
    #                 | GreaterOrEqual
    def __cinit__(self):
        self._fields = ()


cdef class CAdd(CBinaryOp):
    # Add
    def __cinit__(self):
        self._fields = ()


cdef class CSubtract(CBinaryOp):
    # Subtract
    def __cinit__(self):
        self._fields = ()


cdef class CMultiply(CBinaryOp):
    # Multiply
    def __cinit__(self):
        self._fields = ()


cdef class CDivide(CBinaryOp):
    # Divide
    def __cinit__(self):
        self._fields = ()


cdef class CRemainder(CBinaryOp):
    # Remainder
    def __cinit__(self):
        self._fields = ()


cdef class CBitAnd(CBinaryOp):
    # BitAnd
    def __cinit__(self):
        self._fields = ()


cdef class CBitOr(CBinaryOp):
    # BitOr
    def __cinit__(self):
        self._fields = ()


cdef class CBitXor(CBinaryOp):
    # BitXor
    def __cinit__(self):
        self._fields = ()


cdef class CBitShiftLeft(CBinaryOp):
    # BitShiftLeft
    def __cinit__(self):
        self._fields = ()


cdef class CBitShiftRight(CBinaryOp):
    # BitShiftRight
    def __cinit__(self):
        self._fields = ()


cdef class CAnd(CBinaryOp):
    # And
    def __cinit__(self):
        self._fields = ()


cdef class COr(CBinaryOp):
    # Or
    def __cinit__(self):
        self._fields = ()


cdef class CEqual(CBinaryOp):
    # Equal
    def __cinit__(self):
        self._fields = ()


cdef class CNotEqual(CBinaryOp):
    # NotEqual
    def __cinit__(self):
        self._fields = ()


cdef class CLessThan(CBinaryOp):
    # LessThan
    def __cinit__(self):
        self._fields = ()


cdef class CLessOrEqual(CBinaryOp):
    # LessOrEqual
    def __cinit__(self):
        self._fields = ()


cdef class CGreaterThan(CBinaryOp):
    # GreaterThan
    def __cinit__(self):
        self._fields = ()


cdef class CGreaterOrEqual(CBinaryOp):
    # GreaterOrEqual
    def __cinit__(self):
        self._fields = ()


cdef class CExp(AST):
    # exp = Constant(const, type)
    #     | Var(identifier, type)
    #     | Cast(type, exp, type)
    #     | Unary(unary_operator, exp, type)
    #     | Binary(binary_operator, exp, exp, type)
    #     | Assignment(exp, exp, type)
    #     | AssignmentCompound(binary_operator, exp, exp, type)
    #     | Conditional(exp, exp, exp, type)
    #     | FunctionCall(identifier, exp*, type)
    def __cinit__(self):
        self._fields = ()
        self.exp_type = None


cdef class CConstant(CExp):
    # Constant(const constant)
    def __cinit__(self):
        self._fields = ('constant', 'exp_type')

    def __init__(self, CConst constant):
        self.constant = constant


cdef class CVar(CExp):
    # Var(identifier name)
    def __cinit__(self):
        self._fields = ('name', 'exp_type')

    def __init__(self, TIdentifier name):
        self.name = name


cdef class CCast(CExp):
    # Cast(type target_type, exp)
    def __cinit__(self):
        self._fields = ('target_type', 'exp', 'exp_type')

    def __init__(self, CExp exp, Type target_type):
        self.exp = exp
        self.target_type = target_type


cdef class CUnary(CExp):
    # Unary(unary_operator, exp)
    def __cinit__(self):
        self._fields = ('unary_op', 'exp', 'exp_type')

    def __init__(self, CUnaryOp unary_op, CExp exp):
        self.unary_op = unary_op
        self.exp = exp


cdef class CBinary(CExp):
    # Binary(binary_operator, exp, exp)
    def __cinit__(self):
        self._fields = ('binary_op', 'exp_left', 'exp_right', 'exp_type')

    def __init__(self, CBinaryOp binary_op, CExp exp_left, CExp exp_right):
        self.binary_op = binary_op
        self.exp_left = exp_left
        self.exp_right = exp_right


cdef class CAssignment(CExp):
    # Assignment(exp, exp)
    def __cinit__(self):
        self._fields = ('exp_left', 'exp_right', 'exp_type')

    def __init__(self, CExp exp_left, CExp exp_right):
        self.exp_left = exp_left
        self.exp_right = exp_right


cdef class CAssignmentCompound(CExp):
    # AssignmentCompound(binary_operator, exp, exp)
    def __cinit__(self):
        self._fields = ('binary_op', 'exp_left', 'exp_right', 'exp_type')

    def __init__(self, CBinaryOp binary_op, CExp exp_left, CExp exp_right):
        self.binary_op = binary_op
        self.exp_left = exp_left
        self.exp_right = exp_right


cdef class CConditional(CExp):
    # Conditional(exp condition, exp, exp)
    def __cinit__(self):
        self._fields = ('condition', 'exp_middle', 'exp_right', 'exp_type')

    def __init__(self, CExp condition, CExp exp_middle, CExp exp_right):
        self.condition = condition
        self.exp_middle = exp_middle
        self.exp_right = exp_right


cdef class CFunctionCall(CExp):
    # FunctionCall(identifier name, exp* args)
    def __cinit__(self):
        self._fields = ('name', 'args', 'exp_type')

    def __init__(self, TIdentifier name, list[CExp] args):
        self.name = name
        self.args = args


cdef class CStatement(AST):
    # statement = Return(exp)
    #           | Expression(exp)
    #           | If(exp, statement, statement?)
    #           | Goto(identifier)
    #           | Label(identifier, target)
    #           | Compound(block)
    #           | While(exp, statement, identifier)
    #           | DoWhile(statement, exp, identifier)
    #           | For(for_init, exp?, exp?, statement, identifier)
    #           | Break(identifier)
    #           | Continue(identifier)
    #           | Null
    def __cinit__(self):
        self._fields = ()


cdef class CReturn(CStatement):
    # Return(exp)
    def __cinit__(self):
        self._fields = ('exp',)

    def __init__(self, CExp exp):
        self.exp = exp


cdef class CExpression(CStatement):
    # Expression(exp)
    def __cinit__(self):
        self._fields = ('exp',)

    def __init__(self, CExp exp):
        self.exp = exp


cdef class CIf(CStatement):
    # If(exp condition, statement then, statement? else)
    def __cinit__(self):
        self._fields = ('condition', 'then', 'else_fi')

    def __init__(self, CExp condition, CStatement then, CStatement else_fi):
        self.condition = condition
        self.then = then
        self.else_fi = else_fi


cdef class CGoto(CStatement):
    # Goto(identifier target)
    def __cinit__(self):
        self._fields = ('target',)

    def __init__(self, TIdentifier target):
        self.target = target


cdef class CLabel(CStatement):
    # Label(identifier target, statement)
    def __cinit__(self):
        self._fields = ('target', 'jump_to')

    def __init__(self, TIdentifier target, CStatement jump_to):
        self.target = target
        self.jump_to = jump_to


cdef class CCompound(CStatement):
    # Compound(block)
    def __cinit__(self):
        self._fields = ('block',)

    def __init__(self, CBlock block):
        self.block = block


cdef class CWhile(CStatement):
    # While(exp condition, statement body, identifier target)
    def __cinit__(self):
        self._fields = ('condition', 'body', 'target')

    def __init__(self, CExp condition, CStatement body):
        self.condition = condition
        self.body = body
        self.target = None


cdef class CDoWhile(CStatement):
    # DoWhile(statement body, exp condition, identifier target)
    def __cinit__(self):
        self._fields = ('condition', 'body', 'target')

    def __init__(self, CExp condition, CStatement body):
        self.condition = condition
        self.body = body
        self.target = None


cdef class CFor(CStatement):
    # For(for_init init, exp? condition, exp? post, statement body, identifier target)
    def __cinit__(self):
        self._fields = ('init', 'condition', 'post', 'body', 'target')

    def __init__(self, CForInit init, CExp condition, CExp post, CStatement body):
        self.init = init
        self.condition = condition
        self.post = post
        self.body = body
        self.target = None


cdef class CBreak(CStatement):
    # Break(identifier target)
    def __cinit__(self):
        self._fields = ('target',)

    def __init__(self):
        self.target = None


cdef class CContinue(CStatement):
    # Continue(identifier target)
    def __cinit__(self):
        self._fields = ('target',)

    def __init__(self):
        self.target = None


cdef class CNull(CStatement):
    # Null
    def __cinit__(self):
        self._fields = ()


cdef class CForInit(AST):
    # for_init = InitDecl(variable_declaration)
    #          | InitExp(exp?)
    def __cinit__(self):
        self._fields = ()


cdef class CInitDecl(CForInit):
    # InitDecl(variable_declaration)
    def __cinit__(self):
        self._fields = ('init',)

    def __init__(self, CVariableDeclaration init):
        self.init = init


cdef class CInitExp(CForInit):
    # InitExp(exp?)
    def __cinit__(self):
        self._fields = ('init',)

    def __init__(self, CExp init):
        self.init = init


cdef class CBlock(AST):
    # block = B(block_item*)
    def __cinit__(self):
        self._fields = ()


cdef class CB(CBlock):
    # B(block_item* block_items)
    def __cinit__(self):
        self._fields = ('block_items',)

    def __init__(self, list[CBlockItem] block_items):
        self.block_items = block_items


cdef class CBlockItem(AST):
    # block_item = S(statement)
    #            | D(declaration)
    def __cinit__(self):
        self._fields = ()


cdef class CS(CBlockItem):
    # S(statement)
    def __cinit__(self):
        self._fields = ('statement',)

    def __init__(self, CStatement statement):
        self.statement = statement


cdef class CD(CBlockItem):
    # D(declaration)
    def __cinit__(self):
        self._fields = ('declaration',)

    def __init__(self, CDeclaration declaration):
        self.declaration = declaration


cdef class CStorageClass(AST):
    # storage_class = Static
    #               | Extern
    def __cinit__(self):
        self._fields = ()


cdef class CStatic(CStorageClass):
    # Static
    def __cinit__(self):
        self._fields = ()


cdef class CExtern(CStorageClass):
    # Extern
    def __cinit__(self):
        self._fields = ()


cdef class CFunctionDeclaration(AST):
    # function_declaration = FunctionDeclaration(identifier name, identifier* params, block? body, type fun_type, storage_class?)
    def __cinit__(self):
        self._fields = ('name', 'params', 'body', 'fun_type', 'storage_class')

    def __init__(self, TIdentifier name, list[TIdentifier] params, CBlock body, Type fun_type, CStorageClass storage_class):
        self.name = name
        self.params = params
        self.body = body
        self.fun_type = fun_type
        self.storage_class = storage_class


cdef class CVariableDeclaration(AST):
    # variable_declaration = VariableDeclaration(identifier name, exp? init, type var_type, storage_class?)
    def __cinit__(self):
        self._fields = ('name', 'init', 'var_type', 'storage_class')

    def __init__(self, TIdentifier name, CExp init, Type var_type, CStorageClass storage_class):
        self.name = name
        self.init = init
        self.var_type = var_type
        self.storage_class = storage_class


cdef class CDeclaration(AST):
    # declaration = FunDecl(function_declaration)
    #             | VarDecl(variable_declaration)
    def __cinit__(self):
        self._fields = ()


cdef class CFunDecl(CDeclaration):
    # FunDecl(function_declaration function_decl)
    def __cinit__(self):
        self._fields = ('function_decl',)

    def __init__(self, CFunctionDeclaration function_decl):
        self.function_decl = function_decl


cdef class CVarDecl(CDeclaration):
    # VarDecl(variable_declaration)
    def __cinit__(self):
        self._fields = ('variable_decl',)

    def __init__(self, CVariableDeclaration variable_decl):
        self.variable_decl = variable_decl


cdef class CProgram(AST):
    # AST = Program(declaration*)
    def __cinit__(self):
        self._fields = ('declarations',)

    def __init__(self, list[CDeclaration] declarations):
        self.declarations = declarations
