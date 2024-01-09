from ccc.abc_builtin_ast cimport AST


cdef class AssemblyType(AST):
    # assembly_type = LongWord
    #               | QuadWord
    #               | BackendDouble
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


cdef class BackendDouble(AssemblyType):
    # BackendDouble
    def __cinit__(self):
        self._fields = ()


cdef class BackendSymbol(AST):
    # symbol = Obj(type assembly_type, bool is_static, bool is_constant)
    #        | Fun(bool defined)
    def __cinit__(self):
        self._fields = ()


cdef class BackendObj(BackendSymbol):
    # Obj(type assembly_type, bool is_static, bool is_constant)
    def __cinit__(self):
        self._fields = ('assembly_type', 'is_static', 'is_constant')

    def __init__(self, AssemblyType assembly_type, bint is_static, bint is_constant):
        self.assembly_type = assembly_type
        self.is_static = is_static
        self.is_constant = is_constant


cdef class BackendFun(BackendSymbol):
    # Fun(bool defined)
    def __cinit__(self):
        self._fields = ('is_defined',)

    def __init__(self, bint is_defined):
        self.is_defined = is_defined

backend_symbol_table = {}
