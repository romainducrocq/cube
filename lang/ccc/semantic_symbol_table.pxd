cdef class Type:
    pass


cdef class Int(Type):
    pass


cdef class FunType(Type):
    cdef public int param_count
