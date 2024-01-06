from ccc.abc_builtin_ast cimport int32, copy_int, copy_long, copy_uint, copy_ulong
from ccc.abc_builtin_ast cimport copy_int_to_long, copy_int_to_uint, copy_int_to_ulong
from ccc.abc_builtin_ast cimport copy_long_to_int, copy_long_to_uint, copy_long_to_ulong
from ccc.abc_builtin_ast cimport copy_uint_to_int, copy_uint_to_long, copy_uint_to_ulong
from ccc.abc_builtin_ast cimport copy_ulong_to_int, copy_ulong_to_long, copy_ulong_to_uint

from ccc.parser_c_ast cimport CVariableDeclaration, CFunctionDeclaration, CStatic, CExtern, CReturn
from ccc.parser_c_ast cimport CExp, CFunctionCall, CVar, CCast, CConstant, CAssignment, CAssignmentCompound
from ccc.parser_c_ast cimport CUnary, CBinary, CConditional
from ccc.parser_c_ast cimport CNot, CAnd, COr, CAdd, CSubtract, CMultiply, CDivide, CRemainder
from ccc.parser_c_ast cimport CBitAnd, CBitOr, CBitXor, CBitShiftLeft, CBitShiftRight
from ccc.parser_c_ast cimport CConst, CConstInt, CConstLong, CConstUInt, CConstULong

from ccc.semantic_symbol_table cimport *


cdef set[str] defined_set = set()
cdef str function_declaration_name_str = ""


cdef bint is_same_type(Type type1, Type type2):
    return isinstance(type1, type(type2))


cdef bint is_same_fun_type(FunType fun_type1, FunType fun_type2):
    if len(fun_type1.param_types) != len(fun_type2.param_types):
        return False
    if not is_same_type(fun_type1.ret_type, fun_type2.ret_type):
        return False
    cdef Py_ssize_t param_type
    for param_type in range(len(fun_type1.param_types)):
        if not is_same_type(fun_type1.param_types[param_type], fun_type2.param_types[param_type]):
            return False
    return True


cdef int32 get_type_size(Type type1):
    if isinstance(type1, (Int, UInt)):
        return 32
    elif isinstance(type1, (Long, ULong)):
        return 64
    else:
        return -1


cdef bint is_type_signed(Type type1):
    return isinstance(type1, (Int, Long))


cdef bint is_const_signed(CConst node):
    return isinstance(node, (CConstInt, CConstLong))


cdef Type get_joint_type(Type type1, Type type2):
    if is_same_type(type1, type2):
        return type1
    cdef int32 type1_size = get_type_size(type1)
    cdef int32 type2_size = get_type_size(type2)
    if type1_size == type2_size:
        if is_type_signed(type1):
            return type2
        else:
            return type1
    if type1_size > type2_size:
        return type1
    else:
        return type2


cdef void checktype_cast_expression(CCast node):
    node.exp_type = node.target_type


cdef CCast cast_expression(CExp node, Type exp_type):
    cdef CExp exp = CCast(node, exp_type)
    checktype_cast_expression(exp)
    return exp


cdef void checktype_function_call_expression(CFunctionCall node):

    if not isinstance(symbol_table[node.name.str_t].type_t, FunType):

        raise RuntimeError(
            f"Variable {node.name.str_t} was used as a function")

    if len(symbol_table[node.name.str_t].type_t.param_types) != len(node.args):

        raise RuntimeError(
            f"""Function {node.name.str_t} has {len(symbol_table[node.name.str_t].type_t.param_types)} arguments 
                but was called with {len(node.args)}""")

    cdef Py_ssize_t i
    for i in range(len(node.args)):
        if not is_same_type(node.args[i].exp_type, symbol_table[node.name.str_t].type_t.param_types[i]):
            node.args[i] = cast_expression(node.args[i], symbol_table[node.name.str_t].type_t.param_types[i])

    node.exp_type = symbol_table[node.name.str_t].type_t.ret_type


cdef void checktype_var_expression(CVar node):
    if isinstance(symbol_table[node.name.str_t].type_t, FunType):

        raise RuntimeError(
            f"Function {node.name.str_t} was used as a variable")

    node.exp_type = symbol_table[node.name.str_t].type_t


cdef void checktype_constant_expression(CConstant node):
    if isinstance(node.constant, CConstInt):
        node.exp_type = Int()
    elif isinstance(node.constant, CConstLong):
        node.exp_type = Long()
    elif isinstance(node.constant, CConstUInt):
        node.exp_type = UInt()
    elif isinstance(node.constant, CConstULong):
        node.exp_type = ULong()


cdef void checktype_assignment_expression(CAssignment node):
    if not is_same_type(node.exp_right.exp_type, node.exp_left.exp_type):
        node.exp_right = cast_expression(node.exp_right, node.exp_left.exp_type)
    node.exp_type = node.exp_left.exp_type


cdef void checktype_assignment_compound_expression(CAssignmentCompound node):
    cdef Type common_type = get_joint_type(node.exp_left.exp_type, node.exp_right.exp_type)
    if not is_same_type(node.exp_left.exp_type, common_type):
        node.exp_left = cast_expression(node.exp_left, common_type)
    if not is_same_type(node.exp_right.exp_type, common_type):
        node.exp_right = cast_expression(node.exp_right, common_type)
    node.exp_type = common_type


cdef void checktype_unary_expression(CUnary node):
    if isinstance(node.unary_op, CNot):
        node.exp_type = Int()
    else:
        node.exp_type = node.exp.exp_type


cdef void checktype_binary_expression(CBinary node):
    if isinstance(node.binary_op, (CAnd, COr)):
        node.exp_type = Int()
        return
    elif isinstance(node.binary_op, (CBitShiftLeft, CBitShiftRight)):
        # Note: https://stackoverflow.com/a/70130146
        # if the value of the right operand is negative or is greater than or equal
        # to the width of the promoted left operand, the behavior is undefined
        if not is_same_type(node.exp_left.exp_type, node.exp_right.exp_type):
            node.exp_right = cast_expression(node.exp_right, node.exp_left.exp_type)
        node.exp_type = node.exp_left.exp_type
        return
    cdef Type common_type = get_joint_type(node.exp_left.exp_type, node.exp_right.exp_type)
    if not is_same_type(node.exp_left.exp_type, common_type):
        node.exp_left = cast_expression(node.exp_left, common_type)
    if not is_same_type(node.exp_right.exp_type, common_type):
        node.exp_right = cast_expression(node.exp_right, common_type)
    if isinstance(node.binary_op, (CAdd, CSubtract, CMultiply, CDivide, CRemainder)):
        node.exp_type = common_type
    elif isinstance(node.binary_op, (CBitAnd, CBitOr, CBitXor)):
        # Note: https://stackoverflow.com/a/1723938
        # if the value of an operand is a double, it must be cast to integer type
        node.exp_type = common_type
    else:
        node.exp_type = Int()


cdef void checktype_conditional_expression(CConditional node):
    cdef Type common_type = get_joint_type(node.exp_middle.exp_type, node.exp_right.exp_type)
    if not is_same_type(node.exp_middle.exp_type, common_type):
        node.exp_middle = cast_expression(node.exp_middle, common_type)
    if not is_same_type(node.exp_right.exp_type, common_type):
        node.exp_right = cast_expression(node.exp_right, common_type)
    node.exp_type = common_type


cdef void checktype_return_statement(CReturn node):
    if not is_same_type(node.exp.exp_type, symbol_table[function_declaration_name_str].type_t.ret_type):
        node.exp = cast_expression(node.exp, symbol_table[function_declaration_name_str].type_t.ret_type)


cdef Symbol checktype_param(FunType fun_type, Py_ssize_t param):
    cdef Type type_t = fun_type.param_types[param]
    cdef IdentifierAttr param_attrs = LocalAttr()
    return Symbol(type_t, param_attrs)


cdef void checktype_params(CFunctionDeclaration node):
    cdef Py_ssize_t param
    if node.body:
        for param in range(len(node.params)):
            symbol_table[node.params[param].str_t] = checktype_param(node.fun_type, param)


cdef void checktype_function_declaration(CFunctionDeclaration node):
    global function_declaration_name_str

    cdef bint is_defined = node.name.str_t in defined_set
    cdef bint is_global = not isinstance(node.storage_class, CStatic)

    if node.name.str_t in symbol_table:
        if not (isinstance(symbol_table[node.name.str_t].type_t, FunType) and
                len(symbol_table[node.name.str_t].type_t.param_types) == len(node.params) and
                is_same_fun_type(symbol_table[node.name.str_t].type_t, node.fun_type)):

            raise RuntimeError(
                f"Function declaration {node.name.str_t} was redeclared with conflicting type")

        if is_defined and \
           node.body:

                raise RuntimeError(
                    f"Function {node.name.str_t} was already defined")

        if not is_global and \
           symbol_table[node.name.str_t].attrs.is_global:

            raise RuntimeError(
                f"Static function {node.name.str_t} was already defined non-static")

        is_global = symbol_table[node.name.str_t].attrs.is_global

    if node.body:
        defined_set.add(node.name.str_t)
        is_defined = True

    cdef Type fun_type = node.fun_type
    cdef IdentifierAttr fun_attrs = FunAttr(is_defined, is_global)
    symbol_table[node.name.str_t] = Symbol(fun_type, fun_attrs)

    function_declaration_name_str = node.name.str_t


cdef Initial checktype_constant_initial(CConstant node, Type static_init_type):
    if isinstance(static_init_type, Int):
        if isinstance(node.constant, CConstInt):
            return Initial(IntInit(copy_int(node.constant.value)))
        elif isinstance(node.constant, CConstLong):
            return Initial(IntInit(copy_long_to_int(node.constant.value)))
        elif isinstance(node.constant, CConstUInt):
            return Initial(IntInit(copy_uint_to_int(node.constant.value)))
        elif isinstance(node.constant, CConstULong):
            return Initial(IntInit(copy_ulong_to_int(node.constant.value)))
    elif isinstance(static_init_type, Long):
        if isinstance(node.constant, CConstInt):
            return Initial(LongInit(copy_int_to_long(node.constant.value)))
        elif isinstance(node.constant, CConstLong):
            return Initial(LongInit(copy_long(node.constant.value)))
        elif isinstance(node.constant, CConstUInt):
            return Initial(LongInit(copy_uint_to_long(node.constant.value)))
        elif isinstance(node.constant, CConstULong):
            return Initial(LongInit(copy_ulong_to_long(node.constant.value)))
    elif isinstance(static_init_type, UInt):
        if isinstance(node.constant, CConstInt):
            return Initial(UIntInit(copy_int_to_uint(node.constant.value)))
        elif isinstance(node.constant, CConstLong):
            return Initial(UIntInit(copy_long_to_uint(node.constant.value)))
        elif isinstance(node.constant, CConstUInt):
            return Initial(UIntInit(copy_uint(node.constant.value)))
        elif isinstance(node.constant, CConstULong):
            return Initial(UIntInit(copy_ulong_to_uint(node.constant.value)))
    elif isinstance(static_init_type, ULong):
        if isinstance(node.constant, CConstInt):
            return Initial(ULongInit(copy_int_to_ulong(node.constant.value)))
        elif isinstance(node.constant, CConstLong):
            return Initial(ULongInit(copy_long_to_ulong(node.constant.value)))
        elif isinstance(node.constant, CConstUInt):
            return Initial(ULongInit(copy_uint_to_ulong(node.constant.value)))
        elif isinstance(node.constant, CConstULong):
            return Initial(ULongInit(copy_ulong(node.constant.value)))


cdef Initial checktype_no_init_initial(Type static_init_type):
    if isinstance(static_init_type, Int):
        return Initial(IntInit(TInt(0)))
    elif isinstance(static_init_type, Long):
        return Initial(LongInit(TLong(0)))


cdef void checktype_file_scope_variable_declaration(CVariableDeclaration node):
    cdef InitialValue initial_value
    cdef bint is_global = not isinstance(node.storage_class, CStatic)

    if isinstance(node.init, CConstant):
        initial_value = checktype_constant_initial(node.init, node.var_type)
    elif not node.init:
        if isinstance(node.storage_class, CExtern):
            initial_value = NoInitializer()
        else:
            initial_value = Tentative()
    else:

        raise RuntimeError(
            f"File scope variable {node.name.str_t} was initialized to a non-constant")

    if node.name.str_t in symbol_table:
        if not is_same_type(symbol_table[node.name.str_t].type_t, node.var_type):

            raise RuntimeError(
                f"File scope variable {node.name.str_t} was redeclared with conflicting type")

        if isinstance(node.storage_class, CExtern):
            is_global = symbol_table[node.name.str_t].attrs.is_global
        elif is_global != symbol_table[node.name.str_t].attrs.is_global:

            raise RuntimeError(
                f"File scope variable {node.name.str_t} was redeclared with conflicting linkage")

        if isinstance(symbol_table[node.name.str_t].attrs.init, Initial):
            if isinstance(initial_value, Initial):

                raise RuntimeError(
                    f"File scope variable {node.name.str_t} was defined with conflicting linkage")

            else:
                initial_value = symbol_table[node.name.str_t].attrs.init

    cdef Type global_var_type = node.var_type
    cdef IdentifierAttr global_var_attrs = StaticAttr(initial_value, is_global)
    symbol_table[node.name.str_t] = Symbol(global_var_type, global_var_attrs)


cdef void checktype_extern_block_scope_variable_declaration(CVariableDeclaration node):
    if node.init:
        raise RuntimeError(
            f"Block scope variable {node.name.str_t} with external linkage was defined")

    if node.name.str_t in symbol_table:
        if not is_same_type(symbol_table[node.name.str_t].type_t, node.var_type):

            raise RuntimeError(
                f"Block scope variable {node.name.str_t} was redeclared with conflicting type")

        return

    cdef Type local_var_type = node.var_type
    cdef IdentifierAttr local_var_attrs = StaticAttr(NoInitializer(), True)
    symbol_table[node.name.str_t] = Symbol(local_var_type, local_var_attrs)


cdef void checktype_static_block_scope_variable_declaration(CVariableDeclaration node):
    cdef InitialValue initial_value

    if isinstance(node.init, CConstant):
        initial_value = checktype_constant_initial(node.init, node.var_type)
    elif not node.init:
        initial_value = checktype_no_init_initial(node.var_type)
    else:

        raise RuntimeError(
            f"Block scope variable {node.name.str_t} with static linkage was initialized to a non-constant")

    cdef Type local_var_type = node.var_type
    cdef IdentifierAttr local_var_attrs = StaticAttr(initial_value, False)
    symbol_table[node.name.str_t] = Symbol(local_var_type, local_var_attrs)


cdef void checktype_automatic_block_scope_variable_declaration(CVariableDeclaration node):
    cdef Type local_var_type = node.var_type
    cdef IdentifierAttr local_var_attrs = LocalAttr()
    symbol_table[node.name.str_t] = Symbol(local_var_type, local_var_attrs)


cdef void checktype_init_block_scope_variable_declaration(CVariableDeclaration node):
    if node.init and \
       not node.storage_class and \
       not is_same_type(node.var_type, node.init.exp_type):

        node.init = cast_expression(node.init, node.var_type)


cdef void checktype_block_scope_variable_declaration(CVariableDeclaration node):
    if isinstance(node.storage_class, CExtern):
        checktype_extern_block_scope_variable_declaration(node)
    elif isinstance(node.storage_class, CStatic):
        checktype_static_block_scope_variable_declaration(node)
    else:
        checktype_automatic_block_scope_variable_declaration(node)


cdef void init_check_types():
    global function_declaration_name_str
    defined_set.clear()
    function_declaration_name_str = ""
