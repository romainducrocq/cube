cdef class Type:
    pass


cdef class Int(Type):
    pass


cdef class FunType(Type):
    cdef public int param_count


cdef class InitialValue:
    pass


cdef class Tentative(InitialValue):
    pass


cdef class Initial(InitialValue):
    cdef public int value


cdef class NoInitializer(InitialValue):
    pass


cdef class IdentifierAttr:
    pass


cdef class FunAttr(IdentifierAttr):
    cdef public bint is_defined
    cdef public bint is_global


cdef class StaticAttr(IdentifierAttr):
    cdef public InitialValue init
    cdef public bint is_global


cdef class LocalAttr(IdentifierAttr):
    pass
