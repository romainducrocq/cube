from ccc.parser_c_ast cimport CVariableDeclaration, CFunctionDeclaration, CExp, CVar, CFunctionCall

from ccc.semantic_symbol_table cimport *


symbol_table = {}
cdef set[str] defined_set = set()


cdef void checktype_function_call_expression(CFunctionCall node):

    if isinstance(symbol_table[node.name.str_t], Int):
        raise RuntimeError(
            f"Variable {node.name.str_t} was used as a function")

    if symbol_table[node.name.str_t].param_count != len(node.args):
        raise RuntimeError(
            f"""Function {node.name.str_t} has {symbol_table[node.name.str_t].param_count} arguments 
                but was called with {len(node.args)}""")

    cdef int i
    for i in range(len(node.args)):
        checktype_expression(node.args[i])


cdef void checktype_var_expression(CVar node):
    if not isinstance(symbol_table[node.name.str_t], Int):
        raise RuntimeError(
            f"Function {node.name.str_t} was used as a variable")


cdef void checktype_expression(CExp node):
    if isinstance(node, CFunctionCall):
        checktype_function_call_expression(node)
    elif isinstance(node, CVar):
        checktype_var_expression(node)


cdef void checktype_params(CFunctionDeclaration node):
    cdef int param
    cdef Type param_type = Int()
    if node.body:
        for param in range(len(node.params)):
            symbol_table[node.params[param].str_t] = param_type


cdef void checktype_function_declaration(CFunctionDeclaration node):
    cdef Type fun_type = FunType(len(node.params))
    if node.name.str_t in symbol_table:
        if not (isinstance(symbol_table[node.name.str_t], FunType) and
                symbol_table[node.name.str_t].param_count == fun_type.param_count):

            raise RuntimeError(
                f"Function declaration {node.name.str_t} is incompatible with previous declaration")

        if node.body and \
           node.name.str_t in defined_set:

                raise RuntimeError(
                    f"Function {node.name.str_t} was already defined")

    if node.body:
        defined_set.add(node.name.str_t)
    symbol_table[node.name.str_t] = fun_type


cdef void checktype_variable_declaration(CVariableDeclaration node):
    cdef Type var_type = Int()
    symbol_table[node.name.str_t] = var_type


cdef void init_check_types():
    global defined_set
    defined_set = set()
