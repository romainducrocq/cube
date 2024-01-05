from ccc.util_ctypes cimport int32, int64, uint32, uint64


cdef class AST:
    # AST node
    pass


cdef class TIdentifier(AST):
    # identifier str_t
    def __cinit__(self):
        self._fields = ('str_t',)

    def __init__(self, str str_t):
        self.str_t = str_t


cdef class TInt(AST):
    # int int_t
    def __cinit__(self):
        self._fields = ('int_t',)

    def __init__(self, int32 int_t):
        self.int_t = int_t


cdef class TLong(AST):
    # long long_t
    def __cinit__(self):
        self._fields = ('long_t',)

    def __init__(self, int64 long_t):
        self.long_t = long_t


cdef class TUInt(AST):
    # uint uint_t
    def __cinit__(self):
        self._fields = ('uint_t',)

    def __init__(self, uint32 uint_t):
        self.uint_t = uint_t


cdef class TULong(AST):
    # ulong ulong_t
    def __cinit__(self):
        self._fields = ('ulong_t',)

    def __init__(self, uint64 ulong_t):
        self.ulong_t = ulong_t


cdef TIdentifier copy_identifier(TIdentifier node):
    # <identifier> = Built-in identifier type
    return TIdentifier(node.str_t)


cdef TInt copy_int(TInt node):
    # <int> = Built-in int type
    return TInt(node.int_t)


cdef TLong copy_long(TLong node):
    # <long> = Built-in long type
    return TLong(node.long_t)


cdef TUInt copy_uint(TUInt node):
    # <uint> = Built-in unsigned int type
    return TUInt(node.uint_t)


cdef TULong copy_ulong(TULong node):
    # <ulong> = Built-in unsigned long type
    return TULong(node.ulong_t)


cdef TLong copy_int_to_long(TInt node):
    return TLong(<int64>node.int_t)


cdef TUInt copy_int_to_uint(TInt node):
    return TUInt(<uint32>node.int_t)


cdef TULong copy_int_to_ulong(TInt node):
    return TULong(<uint64>node.int_t)


cdef TInt copy_long_to_int(TLong node):
    return TInt(<int32>node.long_t)


cdef TUInt copy_long_to_uint(TLong node):
    return TUInt(<uint32>node.long_t)


cdef TULong copy_long_to_ulong(TLong node):
    return TULong(<uint64>node.long_t)


cdef TInt copy_uint_to_int(TUInt node):
    return TInt(<int32>node.uint_t)


cdef TLong copy_uint_to_long(TUInt node):
    return TLong(<int64>node.uint_t)


cdef TULong copy_uint_to_ulong(TUInt node):
    return TULong(<uint64>node.uint_t)


cdef TInt copy_ulong_to_int(TULong node):
    return TInt(<int32>node.ulong_t)


cdef TLong copy_ulong_to_long(TULong node):
    return TLong(<int64>node.ulong_t)


cdef TUInt copy_ulong_to_uint(TULong node):
    return TUInt(<uint32>node.ulong_t)

#
cdef list[tuple[object, str]] ast_iter_fields(AST node): #
#
    cdef list[tuple[object, str]] fields = [] #
#
    cdef Py_ssize_t name #
    for name in range(len(node._fields)): #
        fields.append((getattr(node, node._fields[name]), node._fields[name])) #
#
    return fields #
#
#
cdef list[tuple[AST, str, Py_ssize_t]] ast_iter_child_nodes(AST node): #
#
    cdef object field #
    cdef list[tuple[AST, str, Py_ssize_t]] child_nodes = [] #
#
    cdef Py_ssize_t name #
    cdef Py_ssize_t item #
    for name in range(len(node._fields)): #
        field = getattr(node, node._fields[name]) #
        if isinstance(field, AST): #
            child_nodes.append((field, node._fields[name], -1)) #
        elif isinstance(field, list): #
            for item in range(len(field)): #
                if isinstance(field[item], AST): #
                    child_nodes.append((field[item], node._fields[name], item)) #
#
    return child_nodes #
#
#
cdef void ast_set_child_node(object field, str name, Py_ssize_t index, AST set_node): #
    if isinstance(field, AST): #
        setattr(field, name, set_node) #
    elif isinstance(getattr(field, name), list): #
        getattr(field, name)[index] = set_node #
