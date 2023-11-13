__all__ = [
    'AST',
    'TIdentifier',
    'TInt',
    'ast_iter_child_nodes',
    'ast_set_child_node',
    'ast_pretty_string'
]


cdef class AST:
    """
    AST node
    """
    pass

cdef class TIdentifier(AST):
    """ identifier str_t """
    def __cinit__(self):
        self._fields = ('str_t',)

    def __init__(self, str str_t):
        self.str_t = str_t


cdef class TInt(AST):
    """ int int_t """
    def __cinit__(self):
        self._fields = ('int_t',)

    def __init__(self, int_t: int):
        self.int_t = int_t


cpdef list[tuple[object, str]] ast_iter_fields(AST node):
    cdef str name
    cdef list[tuple[object, str]] fields

    fields = []
    for name in node._fields:
        fields.append((getattr(node, name), name))

    return fields


cpdef list[tuple[AST, str, int]] ast_iter_child_nodes(AST node):
    cdef int e
    cdef str name
    cdef object field, item
    cdef list[tuple[AST, str, int]] child_nodes

    child_nodes = []
    for name in node._fields:
        field = getattr(node, name)
        if isinstance(field, AST):
            child_nodes.append((field, name, -1))
        elif isinstance(field, list):
            for e, item in enumerate(field):
                if isinstance(item, AST):
                    child_nodes.append((item, name, e))

    return child_nodes


cpdef void ast_set_child_node(object field, str name, int index, AST set_node):
    if isinstance(field, AST):
        setattr(field, name, set_node)
    elif isinstance(getattr(field, name), list):
        getattr(field, name)[index] = set_node


""" pretty string """

cdef str string = ''
cdef int indent = 0


cpdef void _pretty_string_child(str _child_kind, object _child_node):
    global string
    global indent

    if type(_child_node) in (str, int, type(None)):
        string += str(' ' * indent + _child_kind + type(_child_node).__name__ + ': '
                      + str(_child_node) + '\n')
    else:
        _pretty_string(_child_kind, _child_node)


cpdef void _pretty_string(str kind, object node):
    global string
    global indent

    cdef int e
    cdef str child_kind
    cdef object child_node
    cdef list[object] list_node

    string += str(' ' * indent + kind + type(node).__name__ + ':' + '\n')
    indent += 4

    for child_node, child_kind in ast_iter_fields(node):
        if isinstance(child_node, list):
            string += str(' ' * indent + '<' + child_kind + '> List(' + str(len(child_node)) + '):' + '\n')
            indent += 4

            for e, list_node in enumerate(child_node):
                _pretty_string_child('[' + str(e) + '] ', list_node)

            indent -= 4

        else:
            _pretty_string_child('<' + child_kind + '> ', child_node)


cpdef str ast_pretty_string(AST node):
    global string
    global indent

    string = ""
    indent = 0
    _pretty_string('<AST> ', node)
    return string[:-1]
