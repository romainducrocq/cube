from ccc.abc_builtin_ast cimport AST


cdef class AssemblyType(AST):
    # assembly_type = LongWord
    #               | QuadWord
    def __cinit__(self):
        self._fields = ()


cdef class LongWord(AssemblyType):
    # LongWord
    def __cinit__(self):
        self._fields = ()


cdef class QuadWord(AssemblyType):
    # QuadWord
    def __cinit__(self):
        self._fields = ()


cdef class BackendSymbol(AST):
    # symbol = Obj(type assembly_type, bool is_static)
    #        | Fun(bool defined)
    def __cinit__(self):
        self._fields = ()


cdef class BackendObj(BackendSymbol):
    # Obj(type assembly_type, bool is_static)
    def __cinit__(self):
        self._fields = ('assembly_type', 'is_static')

    def __init__(self, AssemblyType assembly_type, bint is_static):
        self.assembly_type = assembly_type
        self.is_static = is_static


cdef class BackendFun(BackendSymbol):
    # Fun(bool defined)
    def __cinit__(self):
        self._fields = ('is_defined',)

    def __init__(self, bint is_defined):
        self.is_defined = is_defined

backend_symbol_table = {}
