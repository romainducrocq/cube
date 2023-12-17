from ccc.abc_builtin_ast cimport AST, TIdentifier, TInt, ast_iter_fields #
#
from ccc.lexer_lexer cimport Token #
#
from ccc.semantic_type_checker cimport symbol_table #
#
from ccc.util_ctypes cimport int32 #
#
#
cdef str pretty_string = '' #
#
#
cdef str header_string(str header): #
    global pretty_string #
#
    pretty_string = "+\n+\n@@ " + header + " @@\n" #
#
#
cdef void pretty_print_tokens(list[Token] tokens): #
    global pretty_string #
#
    header_string("Tokens") #
    cdef Py_ssize_t token #
    for token in range(len(tokens)): #
        pretty_string += str(token) + ': ("' + tokens[token].token + '", ' + str(tokens[token].token_kind) + ')\n' #
    print(pretty_string, end="") #
#
#
cdef int32 indent = 0 #
#
#
cdef void _ast_pretty_string_builtin(str _child_kind, object _child_node): #
    global pretty_string #
#
    if _child_node is None: #
        pretty_string += str(' ' * 4 * indent + _child_kind) + str(_child_node) + '\n' #
        return #
#
    pretty_string += str(' ' * 4 * indent + _child_kind + type(_child_node).__name__ + ': ') #
    if isinstance(_child_node, TIdentifier): #
        pretty_string += str(_child_node.str_t) + '\n' #
    elif isinstance(_child_node, TInt): #
        pretty_string += str(_child_node.int_t) + '\n' #
    else: #
        pretty_string += str(_child_node) + '\n' #
#
#
cdef void _ast_pretty_string_child(str _child_kind, object _child_node): #
    global pretty_string #
    global indent #
#
    if type(_child_node) in (TIdentifier, TInt, bool, type(None)): #
        _ast_pretty_string_builtin(_child_kind, _child_node) #
    else: #
        _ast_pretty_string(_child_kind, _child_node) #
#
#
cdef void _ast_pretty_string(str kind, object node): #
    global pretty_string #
    global indent #
#
    cdef Py_ssize_t item #
    cdef str child_kind #
    cdef object child_node #
#
    pretty_string += str(' ' * 4 * indent + kind + type(node).__name__ + ':' + '\n') #
    indent += 1 #
#
    for child_node, child_kind in ast_iter_fields(node): #
        if isinstance(child_node, list): #
            pretty_string += str(' ' * 4 * indent + '<' + child_kind + '> List(' + str(len(child_node)) + '):' + '\n') #
            indent += 1 #
#
            for item in range(len(child_node)): #
                _ast_pretty_string_child('[' + str(item) + '] ', child_node[item]) #
#
            indent -= 1 #
#
        else: #
            _ast_pretty_string_child('<' + child_kind + '> ', child_node) #
#
    indent -= 1 #
#
#
cdef void pretty_print_ast(AST node): #
    global indent #
    indent = 0 #
#
    header_string("Ast") #
    _ast_pretty_string("<ast> ", node) #
    print(pretty_string, end="") #
#
#
cdef void pretty_print_symbol_table(): #
    global pretty_string #
    global indent #
    indent = 1 #
    #
    header_string("Symbol Table")  #
    cdef str symbol #
    pretty_string += "<symbol_table> Dict(" + str(len(symbol_table)) + "):\n" #
    for symbol in symbol_table: #
        _ast_pretty_string("[" + symbol + "] ", symbol_table[symbol]) #
    print(pretty_string, end="") #
#
#
cdef void pretty_print_asm_code(list[str] asm_code): #
    header_string("Asm Code")  #
    print(pretty_string, end="")  #
    cdef Py_ssize_t code_line #
    for code_line in range(len(asm_code)): #
        print(asm_code[code_line]) #
#
