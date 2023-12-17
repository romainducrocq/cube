from ccc.util_ctypes cimport int32

cdef class AST:
    cdef public tuple[str, ...] _fields

cdef class TIdentifier(AST):
    cdef public str str_t

cdef class TInt(AST):
    cdef public int32 int_t

cdef TInt copy_int(TInt node)
cdef TIdentifier copy_identifier(TIdentifier node)
cdef list[tuple[object, str]] ast_iter_fields(AST node) #
cdef list[tuple[AST, str, Py_ssize_t]] ast_iter_child_nodes(AST node) #
cdef void ast_set_child_node(object field, str name, Py_ssize_t index, AST set_node) #
