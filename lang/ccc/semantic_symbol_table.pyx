from ccc.abc_builtin_ast cimport AST, TInt


cdef class Type(AST):
    # type = Int
    #      | Long
    #      | FunType(type*, type)
    def __cinit__(self):
        self._fields = ()


cdef class Int(Type):
    # Int
    def __cinit__(self):
        self._fields = ()


cdef class Long(Type):
    # Long
    def __cinit__(self):
        self._fields = ()


cdef class FunType(Type):
    # FunType(type* param_types, type ret_type)
    def __cinit__(self):
        self._fields = ('param_types', 'ret_type')

    def __init__(self, list[Type] param_types, Type ret_type):
        self.param_types = param_types
        self.ret_type = ret_type


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

    def __init__(self, TInt value):
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


cdef class Symbol(AST):
    # Symbol(type, identifier_attrs)
    def __cinit__(self):
        self._fields = ('type_t', 'attrs')

    def __init__(self, Type type_t, IdentifierAttr attrs):
        self.type_t = type_t
        self.attrs = attrs


symbol_table = {}
