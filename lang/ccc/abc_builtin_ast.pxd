cdef class AST:
    cdef public tuple[str, ...] _fields

cdef class TIdentifier(AST):
    cdef public str str_t

cdef TIdentifier copy_identifier(TIdentifier node)

cdef class TInt(AST):
    cdef public int int_t

cdef TInt copy_int(TInt node)

cdef list[tuple[object, str]] ast_iter_fields(AST node) #
cdef list[tuple[AST, str, int]] ast_iter_child_nodes(AST node) #
cdef void ast_set_child_node(object field, str name, int index, AST set_node) #
