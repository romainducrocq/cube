from ccc.abc_builtin_ast cimport AST

from ccc.semantic_symbol_table cimport Type


cdef class BackendSymbol(AST):
    pass


cdef class BackendObj(BackendSymbol):
    cdef public Type assembly_type
    cdef public bint is_static


cdef class BackendFun(BackendSymbol):
    cdef public bint is_defined


cdef dict[str, BackendSymbol] backend_symbol_table
