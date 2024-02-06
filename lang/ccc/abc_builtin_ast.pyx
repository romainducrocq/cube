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


cdef class TDouble(AST):
    # double double_t
    def __cinit__(self):
        self._fields = ('double_t',)

    def __init__(self, double double_t):
        self.double_t = double_t


cdef TIdentifier copy_identifier(TIdentifier node):
    # <identifier> = Built-in identifier type
    return TIdentifier(node.str_t)

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
