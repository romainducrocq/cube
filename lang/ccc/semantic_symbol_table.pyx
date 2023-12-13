cdef class Type:
    # type = Int | FunType(int)
    pass


cdef class Int(Type):
    # Int
    pass


cdef class FunType(Type):
    # FunType(int param_count)
    def __init__(self, int param_count):
        self.param_count = param_count


cdef class InitialValue:
    # initial_value = Tentative
    #               | Initial(int)
    #               | NoInitializer
    pass


cdef class Tentative(InitialValue):
    # Tentative
    pass


cdef class Initial(InitialValue):
    # Initial(int)
    def __init__(self, int value):
        self.value = value


cdef class NoInitializer(InitialValue):
    # NoInitializer
    pass


cdef class IdentifierAttr:
    # identifier_attrs = FunAttr(bool defined, bool global)
    #                  | StaticAttr(initial_value init, bool global)
    #                  | LocalAttr
    pass


cdef class FunAttr(IdentifierAttr):
    # FunAttr(bool defined, bool global)
    def __init__(self, bint is_defined, bint is_global):
        self.is_defined = is_defined
        self.is_global = is_global


cdef class StaticAttr(IdentifierAttr):
    # StaticAttr(initial_value init, bool global)
    def __init__(self, InitialValue init, bint is_global):
        self.init = init
        self.is_global = is_global


cdef class LocalAttr(IdentifierAttr):
    # LocalAttr
    pass
