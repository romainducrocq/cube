from ccc.abc_builtin_ast cimport AST, ast_iter_fields #
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
    if type(_child_node) in (str, int, bool, type(None)): #
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
cdef str ast_pretty_string(str kind, AST node, int start_indent): #
    global string #
    global indent #
    string = "" #
    indent = start_indent #
#
    _pretty_string(kind + ' ', node) #
    return string[:-1] #
