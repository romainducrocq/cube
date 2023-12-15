from ccc.util_ast cimport AST


cdef class Type(AST):
    # type = Int | FunType(int)
    def __cinit__(self):
        self._fields = ()


cdef class Int(Type):
    # Int
    def __cinit__(self):
        self._fields = ()


cdef class FunType(Type):
    # FunType(int param_count)
    def __cinit__(self):
        self._fields = ('param_count',)

    def __init__(self, int param_count):
        self.param_count = param_count


cdef class InitialValue(AST):
    # initial_value = Tentative
    #               | Initial(int)
    #               | NoInitializer
    def __cinit__(self):
        self._fields = ()


cdef class Tentative(InitialValue):
    # Tentative
    def __cinit__(self):
        self._fields = ()


cdef class Initial(InitialValue):
    # Initial(int)
    def __cinit__(self):
        self._fields = ('value',)

    def __init__(self, int value):
        self.value = value


cdef class NoInitializer(InitialValue):
    # NoInitializer
    def __cinit__(self):
        self._fields = ()


cdef class IdentifierAttr(AST):
    # identifier_attrs = FunAttr(bool defined, bool global)
    #                  | StaticAttr(initial_value init, bool global)
    #                  | LocalAttr
    def __cinit__(self):
        self._fields = ()


cdef class FunAttr(IdentifierAttr):
    # FunAttr(bool defined, bool global)
    def __cinit__(self):
        self._fields = ('is_defined', 'is_global')

    def __init__(self, bint is_defined, bint is_global):
        self.is_defined = is_defined
        self.is_global = is_global


cdef class StaticAttr(IdentifierAttr):
    # StaticAttr(initial_value init, bool global)
    def __cinit__(self):
        self._fields = ('init', 'is_global')

    def __init__(self, InitialValue init, bint is_global):
        self.init = init
        self.is_global = is_global


cdef class LocalAttr(IdentifierAttr):
    # LocalAttr
    def __cinit__(self):
        self._fields = ()
