from ccc.util_ctypes cimport int32, int64, uint32, uint64

cdef class AST:
    cdef public tuple[str, ...] _fields

cdef class TIdentifier(AST):
    cdef public str str_t

cdef class TInt(AST):
    cdef public int32 int_t

cdef class TLong(AST):
    cdef public int64 long_t

cdef class TUInt(AST):
    cdef public uint32 uint_t

cdef class TULong(AST):
    cdef public uint64 ulong_t

cdef TInt copy_int(TInt node)
cdef TLong copy_long(TLong node)
cdef TUInt copy_uint(TUInt node)
cdef TULong copy_ulong(TULong node)
cdef TInt copy_long_to_int(TLong node)
cdef TLong copy_int_to_long(TInt node)
cdef TIdentifier copy_identifier(TIdentifier node)
cdef list[tuple[object, str]] ast_iter_fields(AST node) #
cdef list[tuple[AST, str, Py_ssize_t]] ast_iter_child_nodes(AST node) #
cdef void ast_set_child_node(object field, str name, Py_ssize_t index, AST set_node) #
