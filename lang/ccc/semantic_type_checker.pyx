from ccc.abc_builtin_ast cimport copy_int

from ccc.parser_c_ast cimport CVariableDeclaration, CFunctionDeclaration, CStatic, CExtern
from ccc.parser_c_ast cimport CExp, CFunctionCall, CVar, CConstant

from ccc.semantic_symbol_table cimport *


cdef set[str] defined_set = set()


cdef void checktype_function_call_expression(CFunctionCall node):

    if isinstance(symbol_table[node.name.str_t].type_t, Int):

        raise RuntimeError(
            f"Variable {node.name.str_t} was used as a function")

    if symbol_table[node.name.str_t].type_t.param_count.int_t != len(node.args):

        raise RuntimeError(
            f"""Function {node.name.str_t} has {symbol_table[node.name.str_t].type_t.param_count.int_t} arguments 
                but was called with {len(node.args)}""")

    cdef Py_ssize_t i
    for i in range(len(node.args)):
        checktype_expression(node.args[i])


cdef void checktype_var_expression(CVar node):
    if not isinstance(symbol_table[node.name.str_t].type_t, Int):

        raise RuntimeError(
            f"Function {node.name.str_t} was used as a variable")


cdef void checktype_expression(CExp node):
    if isinstance(node, CFunctionCall):
        checktype_function_call_expression(node)
    elif isinstance(node, CVar):
        checktype_var_expression(node)


cdef void checktype_params(CFunctionDeclaration node):
    cdef Py_ssize_t param
    cdef Type param_type = Int()
    cdef IdentifierAttr param_attrs = LocalAttr()
    if node.body:
        for param in range(len(node.params)):
            symbol_table[node.params[param].str_t] = Symbol(param_type, param_attrs)


cdef void checktype_function_declaration(CFunctionDeclaration node):
    cdef TInt param_count = TInt(len(node.params))
    cdef bint is_defined = node.name.str_t in defined_set
    cdef bint is_global = not isinstance(node.storage_class, CStatic)

    if node.name.str_t in symbol_table:
        if not (isinstance(symbol_table[node.name.str_t].type_t, FunType) and
                symbol_table[node.name.str_t].type_t.param_count.int_t == param_count.int_t):

            raise RuntimeError(
                f"Function declaration {node.name.str_t} is incompatible with previous declaration")

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

    cdef Type fun_type = FunType(param_count)
    cdef IdentifierAttr fun_attrs = FunAttr(is_defined, is_global)
    symbol_table[node.name.str_t] = Symbol(fun_type, fun_attrs)


cdef void checktype_file_scope_variable_declaration(CVariableDeclaration node):
    cdef InitialValue initial_value
    cdef bint is_global = not isinstance(node.storage_class, CStatic)

    if isinstance(node.init, CConstant):
        initial_value = Initial(copy_int(node.init.value))
    elif not node.init:
        if isinstance(node.storage_class, CExtern):
            initial_value = NoInitializer()
        else:
            initial_value = Tentative()
    else:

        raise RuntimeError(
            f"File scope variable {node.name.str_t} was initialized to a non-constant")

    if node.name.str_t in symbol_table:
        if not (isinstance(symbol_table[node.name.str_t].type_t, Int)):

            raise RuntimeError(
                f"Function {node.name.str_t} was redeclared as a variable")

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

    cdef Type global_var_type = Int()
    cdef IdentifierAttr global_var_attrs = StaticAttr(initial_value, is_global)
    symbol_table[node.name.str_t] = Symbol(global_var_type, global_var_attrs)


cdef void checktype_extern_block_scope_variable_declaration(CVariableDeclaration node):
    if node.init:
        raise RuntimeError(
            f"Block scope variable {node.name.str_t} with external linkage was defined")

    if node.name.str_t in symbol_table:
        if not (isinstance(symbol_table[node.name.str_t].type_t, Int)):
            raise RuntimeError(
                f"Function {node.name.str_t} was redeclared as a variable")

        return

    cdef Type local_var_type = Int()
    cdef IdentifierAttr local_var_attrs = StaticAttr(NoInitializer(), True)
    symbol_table[node.name.str_t] = Symbol(local_var_type, local_var_attrs)


cdef void checktype_static_block_scope_variable_declaration(node):
    cdef InitialValue initial_value

    if isinstance(node.init, CConstant):
        initial_value = Initial(copy_int(node.init.value))
    elif not node.init:
        initial_value = Initial(TInt(0))
    else:

        raise RuntimeError(
            f"Block scope variable {node.name.str_t} with static linkage was initialized to a non-constant")

    cdef Type local_var_type = Int()
    cdef IdentifierAttr local_var_attrs = StaticAttr(initial_value, False)
    symbol_table[node.name.str_t] = Symbol(local_var_type, local_var_attrs)


cdef void checktype_automatic_block_scope_variable_declaration(node):
    cdef Type local_var_type = Int()
    cdef IdentifierAttr local_var_attrs = LocalAttr()
    symbol_table[node.name.str_t] = Symbol(local_var_type, local_var_attrs)


cdef void checktype_block_scope_variable_declaration(CVariableDeclaration node):
    if isinstance(node.storage_class, CExtern):
        checktype_extern_block_scope_variable_declaration(node)
    elif isinstance(node.storage_class, CStatic):
        checktype_static_block_scope_variable_declaration(node)
    else:
        checktype_automatic_block_scope_variable_declaration(node)


cdef void init_check_types():
    defined_set.clear()
