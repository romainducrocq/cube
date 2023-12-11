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

    def __init__(self, int int_t):
        self.int_t = int_t

#
cdef list[tuple[object, str]] ast_iter_fields(AST node): #
#
    cdef list[tuple[object, str]] fields = [] #
#
    cdef int name #
    for name in range(len(node._fields)): #
        fields.append((getattr(node, node._fields[name]), node._fields[name])) #
#
    return fields #
#
#
cdef list[tuple[AST, str, int]] ast_iter_child_nodes(AST node): #
#
    cdef object field #
    cdef list[tuple[AST, str, int]] child_nodes = [] #
#
    cdef int name #
    cdef int item #
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
cdef void ast_set_child_node(object field, str name, int index, AST set_node): #
    if isinstance(field, AST): #
        setattr(field, name, set_node) #
    elif isinstance(getattr(field, name), list): #
        getattr(field, name)[index] = set_node #
#
#
# pretty string
#
#
cdef str string = '' #
cdef int indent = 0 #
#
#
cdef void _pretty_string_child(str _child_kind, object _child_node): #
    global string #
    global indent #
#
    if type(_child_node) in (str, int, type(None)): #
        string += str(' ' * indent + _child_kind + type(_child_node).__name__ + ': ' #
                      + str(_child_node) + '\n') #
    else: #
        _pretty_string(_child_kind, _child_node) #
#
#
cdef void _pretty_string(str kind, object node): #
    global string #
    global indent #
#
    cdef int item #
    cdef str child_kind #
    cdef object child_node #
#
    string += str(' ' * indent + kind + type(node).__name__ + ':' + '\n') #
    indent += 4 #
#
    for child_node, child_kind in ast_iter_fields(node): #
        if isinstance(child_node, list): #
            string += str(' ' * indent + '<' + child_kind + '> List(' + str(len(child_node)) + '):' + '\n') #
            indent += 4 #
#
            for item in range(len(child_node)): #
                _pretty_string_child('[' + str(item) + '] ', child_node[item]) #
#
            indent -= 4 #
#
        else: #
            _pretty_string_child('<' + child_kind + '> ', child_node) #
#
    indent -= 4 #
#
#
cdef str ast_pretty_string(AST node): #
    global string #
    global indent #
    string = "" #
    indent = 0 #
#
    _pretty_string('<AST> ', node) #
    return string[:-1] #
