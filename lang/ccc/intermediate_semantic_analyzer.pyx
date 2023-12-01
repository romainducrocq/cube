from ccc.parser_c_ast cimport TIdentifier, CProgram, CFunctionDef, CFunction, CBlock, CB, CBlockItem, CD, CS
from ccc.parser_c_ast cimport CDeclaration, CDecl, CStatement, CReturn, CExpression, CIf, CLabel, CGoto, CCompound
from ccc.parser_c_ast cimport CWhile, CDoWhile, CFor, CBreak, CContinue, CForInit, CInitDecl, CInitExp, CNull
from ccc.parser_c_ast cimport CExp, CVar, CConstant, CUnary, CBinary, CAssignment, CAssignmentCompound, CConditional

from ccc.intermediate_name cimport resolve_label_identifier, resolve_variable_identifier


cdef list[dict[str, str]] scoped_variable_maps = [{}]

cdef dict[str, str] goto_map = {}
cdef set[str] label_set = set()


cdef void resolve_for_init(CForInit node):
    if isinstance(node, CInitDecl):
        resolve_declaration(node.init)
        return
    if isinstance(node, CInitExp):
        if node:
            resolve_expression(node.init)
        return

    raise RuntimeError(
        "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_statement(CStatement node):
    if isinstance(node, (CNull, CBreak, CContinue)):
        return
    if isinstance(node, (CReturn, CExpression)):
        resolve_expression(node.exp)
        return
    if isinstance(node, CCompound):
        scoped_variable_maps.append({})
        resolve_block(node.block)
        del scoped_variable_maps[-1]
        return
    if isinstance(node, CIf):
        resolve_expression(node.condition)
        resolve_statement(node.then)
        if node.else_fi:
            resolve_statement(node.else_fi)
        return
    if isinstance(node, CWhile):
        resolve_expression(node.condition)
        resolve_statement(node.body)
        return
    if isinstance(node, CDoWhile):
        resolve_statement(node.body)
        resolve_expression(node.condition)
        return
    if isinstance(node, CFor):
        scoped_variable_maps.append({})
        resolve_for_init(node.init)
        if node.condition:
            resolve_expression(node.condition)
        if node.post:
            resolve_expression(node.post)
        resolve_statement(node.body)
        del scoped_variable_maps[-1]
        return
    cdef TIdentifier target
    if isinstance(node, CLabel):
        if node.target in label_set:

            raise RuntimeError(
                f"Label {node.target.str_t} was already declared in this scope")

        label_set.add(node.target.str_t)
        if node.target.str_t in goto_map:
            target = TIdentifier(goto_map[node.target.str_t])
            node.target = target
        else:
            target = resolve_label_identifier(node.target)
            goto_map[node.target.str_t] = target.str_t
            node.target = target
        resolve_statement(node.jump_to)
        return
    if isinstance(node, CGoto):
        if node.target.str_t in goto_map:
            target = TIdentifier(goto_map[node.target.str_t])
            node.target = target
        else:
            target = resolve_label_identifier(node.target)
            goto_map[node.target.str_t] = target.str_t
            node.target = target
        return

    raise RuntimeError(
        "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_declaration(CDeclaration node):
    global scoped_variable_maps

    cdef TIdentifier name
    if isinstance(node, CDecl):
        if node.name.str_t in scoped_variable_maps[-1]:

            raise RuntimeError(
                f"Variable {node.name.str_t} was already declared in this scope")

        name = resolve_variable_identifier(node.name)
        scoped_variable_maps[-1][node.name.str_t] = name.str_t
        node.name = name
        if node.init:
            resolve_expression(node.init)
        return

    raise RuntimeError(
        "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_expression(CExp node):
    if isinstance(node, CConstant):
        return
    if isinstance(node, (CAssignment, CAssignmentCompound)):
        if not isinstance(node.exp_left, CVar):

            raise RuntimeError(
                f"Left expression {type(node.exp_left)} is an invalid lvalue")

        resolve_expression(node.exp_left)
        resolve_expression(node.exp_right)
        return
    if isinstance(node, CUnary):
        resolve_expression(node.exp)
        return
    if isinstance(node, CBinary):
        resolve_expression(node.exp_left)
        resolve_expression(node.exp_right)
        return
    if isinstance(node, CConditional):
        resolve_expression(node.condition)
        resolve_expression(node.exp_middle)
        resolve_expression(node.exp_right)
        return

    cdef int i
    cdef int scope
    cdef TIdentifier name
    if isinstance(node, CVar):
        for scope in range(len(scoped_variable_maps)):
            i = - (scope + 1)
            if node.name.str_t in scoped_variable_maps[i]:
                name = TIdentifier(scoped_variable_maps[i][node.name.str_t])
                node.name = name
                break
        else:

            raise RuntimeError(
                f"Variable {node.name.str_t} was not declared in this scope")
        return

    raise RuntimeError(
        "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_block_items(list[CBlockItem] list_node):

    cdef int block_item
    for block_item in range(len(list_node)):
        if isinstance(list_node[block_item], CS):
            resolve_statement(list_node[block_item].statement)
        elif isinstance(list_node[block_item], CD):
            resolve_declaration(list_node[block_item].declaration)
        else:

            raise RuntimeError(
                "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_block(CBlock node):
    if isinstance(node, CB):
        resolve_block_items(node.block_items)
        return

    raise RuntimeError(
        "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_label():
    cdef str target
    for target in goto_map:
        if not target in label_set:

            raise RuntimeError(
                f"An error occurred in semantic analysis, goto \"{target}\" has no target label")


cdef void resolve_function_def(CFunctionDef node):
    global goto_map
    global label_set

    if isinstance(node, CFunction):
        goto_map = {}
        label_set = set()
        resolve_block(node.body)
        resolve_label()
        return

    raise RuntimeError(
        "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_variable(CProgram node):
    resolve_function_def(node.function_def)


cdef void semantic_analysis(CProgram c_ast):
    global scoped_variable_maps
    scoped_variable_maps = [{}]

    resolve_variable(c_ast)
