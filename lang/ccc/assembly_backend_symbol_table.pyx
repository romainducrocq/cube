from ccc.abc_builtin_ast cimport AST

from ccc.semantic_symbol_table cimport Type


cdef class BackendSymbolEntry(AST):
    # symbol = Obj(type assembly_type, bool is_static)
    #        | Fun(bool defined)
    def __cinit__(self):
        self._fields = ()


cdef class BackendObj(BackendSymbol):
    # Obj(type assembly_type, bool is_static)
    def __cinit__(self):
        self._fields = ('assembly_type', 'is_static')

    def __init__(self, Type assembly_type, bint is_static):
        self.assembly_type = assembly_type
        self.is_static = is_static


cdef class BackendFun(BackendSymbol):
    # Fun(bool defined)
    def __cinit__(self):
        self._fields = ('is_defined',)

    def __init__(self, bint is_defined):
        self.is_defined = is_defined

backend_symbol_table = {}
