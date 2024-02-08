from ccc.semantic_symbol_table cimport symbol_table, Int, Long, Double, UInt, ULong, FunType
from ccc.semantic_symbol_table cimport IdentifierAttr, FunAttr, StaticAttr, DoubleInit
from ccc.assembly_asm_ast cimport AsmProgram, AsmTopLevel, AsmStaticConstant

from ccc.assembly_backend_symbol_table cimport *


cdef AssemblyType convert_backend_assembly_type(str name_str):
    if isinstance(symbol_table[name_str].type_t, (Int, UInt)):
        return LongWord()
    elif isinstance(symbol_table[name_str].type_t, Double):
        return BackendDouble()
    elif isinstance(symbol_table[name_str].type_t, (Long, ULong)):
        return QuadWord()
    else:

        raise RuntimeError(
            "An error occurred in backend symbol table conversion, not all nodes were visited")


cdef str symbol = ""


cdef void add_backend_symbol(BackendSymbol node):
    backend_symbol_table[symbol] = node


cdef void convert_double_static_constant():
    cdef AssemblyType assembly_type = BackendDouble()
    cdef bint is_static = True
    cdef bint is_constant = True
    add_backend_symbol(BackendObj(assembly_type, is_static, is_constant))


cdef void convert_static_constant_top_level(AsmStaticConstant node):
    global symbol

    symbol = node.name.str_t
    if isinstance(node.initial_value, DoubleInit):
        convert_double_static_constant()
    else:

        raise RuntimeError(
            "An error occurred in backend symbol table conversion, not all nodes were visited")


cdef void convert_top_level(AsmTopLevel node):
    if isinstance(node, AsmStaticConstant):
        convert_static_constant_top_level(node)
    else:

        raise RuntimeError(
            "An error occurred in stack management, not all nodes were visited")


cdef void convert_fun_type(FunAttr node):
    cdef bint is_defined = node.is_defined
    add_backend_symbol(BackendFun(is_defined))


cdef void convert_obj_type(IdentifierAttr node):
    cdef AssemblyType assembly_type = convert_backend_assembly_type(symbol)
    cdef bint is_static = isinstance(node, StaticAttr)
    cdef bint is_constant = False
    add_backend_symbol(BackendObj(assembly_type, is_static, is_constant))


cdef void convert_backend_symbol_table(AsmProgram node):
    global symbol

    cdef Py_ssize_t top_level
    for top_level in range(len(node.static_constant_top_levels)):
        convert_top_level(node.static_constant_top_levels[top_level])

    for symbol in symbol_table:
        if isinstance(symbol_table[symbol].type_t, FunType):
            convert_fun_type(symbol_table[symbol].attrs)
        else:
            convert_obj_type(symbol_table[symbol].attrs)


cdef void convert_symbol_table(AsmProgram asm_ast):
    convert_backend_symbol_table(asm_ast)
