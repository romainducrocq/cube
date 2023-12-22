from ccc.semantic_symbol_table cimport symbol_table, Int, Long, FunType
from ccc.semantic_symbol_table cimport IdentifierAttr, FunAttr, StaticAttr

from ccc.assembly_backend_symbol_table cimport *


cdef str symbol = ""


cdef void add_backend_symbol(BackendSymbol node):
    backend_symbol_table[symbol] = node


cdef void convert_fun_type(FunAttr node):
    cdef bint is_defined = node.is_defined
    add_backend_symbol(BackendFun(is_defined))


cdef void convert_obj_type(IdentifierAttr node, Type assembly_type):
    cdef bint is_static = False
    if isinstance(node, StaticAttr):
        is_static = True
    add_backend_symbol(BackendObj(assembly_type, is_static))


cdef void convert_symbol_table():
    global symbol

    for symbol in symbol_table:
        if isinstance(symbol_table[symbol].type_t, FunType):
            convert_fun_type(symbol_table[symbol].attrs)
        elif isinstance(symbol_table[symbol].type_t, Int):
            convert_obj_type(symbol_table[symbol].attrs, Int())
        elif isinstance(symbol_table[symbol].type_t, Long):
            convert_obj_type(symbol_table[symbol].attrs, Long())
        else:

            raise RuntimeError(
                f"An error occurred in backend symbol table conversion, \"{symbol}\" has invalid type")
