cdef class Type:
    # Type = Int | FunType(int)
    pass


cdef class Int(Type):
    # Int
    pass


cdef class FunType(Type):
    # FunType(int param_count)
    def __init__(self, int param_count):
        self.param_count = param_count
