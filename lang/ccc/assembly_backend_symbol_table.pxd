from ccc.abc_builtin_ast cimport AST


cdef class AssemblyType(AST):
    pass


cdef class LongWord(AssemblyType):
    pass


cdef class QuadWord(AssemblyType):
    pass


cdef class BackendDouble(AssemblyType):
    pass


cdef class BackendSymbol(AST):
    pass


cdef class BackendObj(BackendSymbol):
    cdef public AssemblyType assembly_type
    cdef public bint is_static
    cdef public bint is_constant


cdef class BackendFun(BackendSymbol):
    cdef public bint is_defined


cdef dict[str, BackendSymbol] backend_symbol_table
