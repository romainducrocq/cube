from ccc.parser_c_ast cimport TIdentifier, CProgram, CFunctionDeclaration, CVariableDeclaration
from ccc.parser_c_ast cimport CDeclaration, CFunDecl, CVarDecl, CStatic, CExtern, CBlock, CB, CBlockItem, CD, CS
from ccc.parser_c_ast cimport CStatement, CReturn, CExpression, CIf, CLabel, CGoto, CCompound
from ccc.parser_c_ast cimport CWhile, CDoWhile, CFor, CBreak, CContinue, CForInit, CInitDecl, CInitExp, CNull
from ccc.parser_c_ast cimport CExp, CFunctionCall, CVar, CConstant, CAssignment, CAssignmentCompound
from ccc.parser_c_ast cimport CUnary, CBinary, CConditional

from ccc.semantic_name cimport resolve_label_identifier, resolve_variable_identifier
from ccc.semantic_loop_annotater cimport annotate_while_loop, annotate_do_while_loop, annotate_for_loop
from ccc.semantic_loop_annotater cimport annotate_break_loop, annotate_continue_loop, deannotate_loop
from ccc.semantic_loop_annotater cimport init_annotate_loops

from ccc.semantic_type_checker cimport checktype_params, checktype_function_declaration
from ccc.semantic_type_checker cimport checktype_file_scope_variable_declaration, checktype_block_scope_variable_declaration
from ccc.semantic_type_checker cimport checktype_function_call_expression, checktype_var_expression, init_check_types


cdef set[str] external_linkage_set = set()
cdef list[dict[str, str]] scoped_identifier_maps = [{}]

cdef dict[str, str] goto_map = {}
cdef set[str] label_set = set()


cdef bint is_file_scope():
    return len(scoped_identifier_maps) == 1


cdef void enter_scope():
    scoped_identifier_maps.append({})


cdef void exit_scope():
    cdef str identifier
    for identifier in scoped_identifier_maps[-1]:
        external_linkage_set.discard(identifier)
    del scoped_identifier_maps[-1]


cdef void resolve_label():
    cdef str target
    for target in goto_map:
        if not target in label_set:

            raise RuntimeError(
                f"An error occurred in variable resolution, goto \"{target}\" has no target label")


cdef void resolve_function_call_expression(CFunctionCall node):
    cdef int i
    cdef int scope
    cdef TIdentifier name
    for scope in range(len(scoped_identifier_maps)):
        i = - (scope + 1)
        if node.name.str_t in scoped_identifier_maps[i]:
            name = TIdentifier(scoped_identifier_maps[i][node.name.str_t])
            node.name = name
            break
    else:

        raise RuntimeError(
            f"Function {node.name.str_t} was not declared in this scope")

    for i in range(len(node.args)):
        resolve_expression(node.args[i])


cdef void resolve_var_expression(CVar node):
    cdef int i
    cdef int scope
    cdef TIdentifier name
    for scope in range(len(scoped_identifier_maps)):
        i = - (scope + 1)
        if node.name.str_t in scoped_identifier_maps[i]:
            name = TIdentifier(scoped_identifier_maps[i][node.name.str_t])
            node.name = name
            break
    else:

        raise RuntimeError(
            f"Variable {node.name.str_t} was not declared in this scope")


cdef void resolve_constant_expression(CConstant node):
    pass


cdef void resolve_assignment_expression(CAssignment node):
    if not isinstance(node.exp_left, CVar):
        raise RuntimeError(
            f"Left expression {type(node.exp_left)} is an invalid lvalue")

    resolve_expression(node.exp_left)
    resolve_expression(node.exp_right)


cdef void resolve_assignment_compound_expression(CAssignmentCompound node):
    if not isinstance(node.exp_left, CVar):
        raise RuntimeError(
            f"Left expression {type(node.exp_left)} is an invalid lvalue")

    resolve_expression(node.exp_left)
    resolve_expression(node.exp_right)


cdef void resolve_unary_expression(CUnary node):
    resolve_expression(node.exp)


cdef void resolve_binary_expression(CBinary node):
    resolve_expression(node.exp_left)
    resolve_expression(node.exp_right)


cdef void resolve_conditional_expression(CConditional node):
    resolve_expression(node.condition)
    resolve_expression(node.exp_middle)
    resolve_expression(node.exp_right)


cdef void resolve_expression(CExp node):
    if isinstance(node, CFunctionCall):
        resolve_function_call_expression(node)
        checktype_function_call_expression(node)
    elif isinstance(node, CVar):
        resolve_var_expression(node)
        checktype_var_expression(node)
    elif isinstance(node, CConstant):
        resolve_constant_expression(node)
    elif isinstance(node, CAssignment):
        resolve_assignment_expression(node)
    elif isinstance(node, CAssignmentCompound):
        resolve_assignment_compound_expression(node)
    elif isinstance(node, CUnary):
        resolve_unary_expression(node)
    elif isinstance(node, CBinary):
        resolve_binary_expression(node)
    elif isinstance(node, CConditional):
        resolve_conditional_expression(node)
    else:

        raise RuntimeError(
            "An error occurred in variable resolution, not all nodes were visited")


cdef void resolve_for_init(CForInit node):
    if isinstance(node, CInitDecl):
        resolve_block_scope_variable_declaration(node.init)
    elif isinstance(node, CInitExp):
        if node.init:
            resolve_expression(node.init)
    else:

        raise RuntimeError(
            "An error occurred in variable resolution, not all nodes were visited")


cdef void resolve_null_statement(CNull node):
    pass


cdef void resolve_return_statement(CReturn node):
    resolve_expression(node.exp)


cdef void resolve_expression_statement(CExpression node):
    resolve_expression(node.exp)


cdef void resolve_compound_statement(CCompound node):
    enter_scope()
    resolve_block(node.block)
    exit_scope()


cdef void resolve_if_statement(CIf node):
    resolve_expression(node.condition)
    resolve_statement(node.then)
    if node.else_fi:
        resolve_statement(node.else_fi)


cdef void resolve_while_statement(CWhile node):
    annotate_while_loop(node)
    resolve_expression(node.condition)
    resolve_statement(node.body)
    deannotate_loop()


cdef void resolve_do_while_statement(CDoWhile node):
    annotate_do_while_loop(node)
    resolve_statement(node.body)
    resolve_expression(node.condition)
    deannotate_loop()


cdef void resolve_for_statement(CFor node):
    annotate_for_loop(node)
    enter_scope()
    resolve_for_init(node.init)
    if node.condition:
        resolve_expression(node.condition)
    if node.post:
        resolve_expression(node.post)
    resolve_statement(node.body)
    exit_scope()
    deannotate_loop()


cdef void resolve_break_statement(CBreak node):
    annotate_break_loop(node)


cdef void resolve_continue_statement(CContinue node):
    annotate_continue_loop(node)


cdef void resolve_label_statement(CLabel node):
    if node.target.str_t in label_set:

        raise RuntimeError(
            f"Label {node.target.str_t} was already declared in this scope")

    label_set.add(node.target.str_t)

    cdef TIdentifier target
    if node.target.str_t in goto_map:
        target = TIdentifier(goto_map[node.target.str_t])
        node.target = target
    else:
        target = resolve_label_identifier(node.target)
        goto_map[node.target.str_t] = target.str_t
        node.target = target
    resolve_statement(node.jump_to)


cdef void resolve_goto_statement(CGoto node):
    cdef TIdentifier target
    if node.target.str_t in goto_map:
        target = TIdentifier(goto_map[node.target.str_t])
        node.target = target
    else:
        target = resolve_label_identifier(node.target)
        goto_map[node.target.str_t] = target.str_t
        node.target = target


cdef void resolve_statement(CStatement node):
    if isinstance(node, CNull):
        resolve_null_statement(node)
    elif isinstance(node, CReturn):
        resolve_return_statement(node)
    elif isinstance(node, CExpression):
        resolve_expression_statement(node)
    elif isinstance(node, CCompound):
        resolve_compound_statement(node)
    elif isinstance(node, CIf):
        resolve_if_statement(node)
    elif isinstance(node, CWhile):
        resolve_while_statement(node)
    elif isinstance(node, CDoWhile):
        resolve_do_while_statement(node)
    elif isinstance(node, CFor):
        resolve_for_statement(node)
    elif isinstance(node, CBreak):
        resolve_break_statement(node)
    elif isinstance(node, CContinue):
        resolve_continue_statement(node)
    elif isinstance(node, CLabel):
        resolve_label_statement(node)
    elif isinstance(node, CGoto):
        resolve_goto_statement(node)
    else:

        raise RuntimeError(
            "An error occurred in variable resolution, not all nodes were visited")


cdef void resolve_block_items(list[CBlockItem] list_node):

    cdef int block_item
    for block_item in range(len(list_node)):
        if isinstance(list_node[block_item], CS):
            resolve_statement(list_node[block_item].statement)
        elif isinstance(list_node[block_item], CD):
            resolve_declaration(list_node[block_item].declaration)
        else:

            raise RuntimeError(
                "An error occurred in variable resolution, not all nodes were visited")


cdef void resolve_block(CBlock node):
    if isinstance(node, CB):
        resolve_block_items(node.block_items)
    else:

        raise RuntimeError(
            "An error occurred in variable resolution, not all nodes were visited")


cdef void resolve_params(CFunctionDeclaration node):
    cdef int param
    cdef TIdentifier name
    for param in range(len(node.params)):
        if node.params[param].str_t in scoped_identifier_maps[-1]:
            raise RuntimeError(
                f"Variable {node.params[param]} was already declared in this scope")

        name = resolve_variable_identifier(node.params[param])
        scoped_identifier_maps[-1][node.params[param].str_t] = name.str_t
        node.params[param] = name

    if node.body:
        checktype_params(node)


cdef void resolve_function_declaration(CFunctionDeclaration node):
    global scoped_identifier_maps

    if not is_file_scope():
        if node.body:
            raise RuntimeError(
                f"Block scoped function definition {node.name.str_t} can not be nested")

        if isinstance(node.storage_class, CStatic):
            raise RuntimeError(
                f"Block scoped function definition {node.name.str_t} can not be static")

    if node.name.str_t in scoped_identifier_maps[-1] and \
       node.name.str_t not in external_linkage_set:
        raise RuntimeError(
            f"Function {node.name.str_t} was already declared in this scope")

    external_linkage_set.add(node.name.str_t)
    scoped_identifier_maps[-1][node.name.str_t] = node.name.str_t
    checktype_function_declaration(node)

    enter_scope()
    if node.params:
        resolve_params(node)
    if node.body:
        resolve_block(node.body)
    exit_scope()


cdef void resolve_file_scope_variable_declaration(CVariableDeclaration node):
    global scoped_identifier_maps

    external_linkage_set.add(node.name.str_t)
    scoped_identifier_maps[-1][node.name.str_t] = node.name.str_t
    if is_file_scope():
        checktype_file_scope_variable_declaration(node)
    else:
        checktype_block_scope_variable_declaration(node)


cdef void resolve_block_scope_variable_declaration(CVariableDeclaration node):
    global scoped_identifier_maps

    if node.name.str_t in scoped_identifier_maps[-1] and \
        not (node.name.str_t in external_linkage_set and
             isinstance(node.storage_class, CExtern)):
        raise RuntimeError(
            f"Variable {node.name.str_t} was already declared in this scope")

    if isinstance(node.storage_class, CExtern):
        resolve_file_scope_variable_declaration(node)
        return

    cdef TIdentifier name = resolve_variable_identifier(node.name)
    scoped_identifier_maps[-1][node.name.str_t] = name.str_t
    node.name = name
    checktype_block_scope_variable_declaration(node)

    if node.init and \
       not node.storage_class:
        resolve_expression(node.init)


cdef void resolve_fun_decl_declaration(CFunDecl node):
    if is_file_scope():
        init_resolve_labels()
        init_annotate_loops()
    resolve_function_declaration(node.function_decl)
    if is_file_scope():
        resolve_label()


cdef void resolve_var_decl_declaration(CVarDecl node):
    if is_file_scope():
        resolve_file_scope_variable_declaration(node.variable_decl)
    else:
        resolve_block_scope_variable_declaration(node.variable_decl)


cdef void resolve_declaration(CDeclaration node):
    if isinstance(node, CFunDecl):
        resolve_fun_decl_declaration(node)
    elif isinstance(node, CVarDecl):
        resolve_var_decl_declaration(node)
    else:

        raise RuntimeError(
            "An error occurred in variable resolution, not all nodes were visited")


cdef void init_resolve_labels():
    global goto_map
    global label_set
    goto_map = {}
    label_set = set()


cdef void init_resolve_identifiers():
    global external_linkage_set
    global scoped_identifier_maps
    external_linkage_set = set()
    scoped_identifier_maps = [{}]


cdef void resolve_identifiers(CProgram node):
    init_resolve_identifiers()
    init_check_types()

    cdef int declaration
    for declaration in range(len(node.declarations)):
        resolve_declaration(node.declarations[declaration])
        resolve_label()


cdef void analyze_semantic(CProgram c_ast):

    resolve_identifiers(c_ast)
