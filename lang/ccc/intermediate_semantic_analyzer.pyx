from ccc.util_ast cimport ast_iter_child_nodes
from ccc.parser_c_ast cimport AST, TIdentifier, CFunction, CBlockItem
from ccc.parser_c_ast cimport CD, CDeclaration, CDecl, CS, CStatement, CReturn, CExpression, CIf, CNull
from ccc.parser_c_ast cimport CExp, CVar, CConstant, CUnary, CBinary, CAssignment, CAssignmentCompound, CConditional
from ccc.intermediate_name cimport resolve_variable_identifier


cdef dict[str, str] variable_map = {}


cdef void resolve_statement(CStatement node):
    if isinstance(node, (CReturn, CExpression)):
        resolve_expression(node.exp)
        return
    if isinstance(node, CIf):
        resolve_expression(node.condition)
        resolve_statement(node.then)
        if node.else_fi:
            resolve_statement(node.else_fi)
        return
    if isinstance(node, CNull):
        return

    raise RuntimeError(
        "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_declaration(CDeclaration node):
    global variable_map

    cdef TIdentifier name
    if isinstance(node, CDecl):
        if node.name.str_t in variable_map:

            raise RuntimeError(
                f"Variable {node.name.str_t} was already declared in this scope")

        name = resolve_variable_identifier(node.name)
        variable_map[node.name.str_t] = name.str_t
        node.name = name
        if node.init:
            resolve_expression(node.init)
        return

    raise RuntimeError(
        "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_expression(CExp node):
    if isinstance(node, CConstant):
        return
    cdef TIdentifier name
    if isinstance(node, CVar):
        if node.name.str_t in variable_map:
            name = TIdentifier(variable_map[node.name.str_t])
            node.name = name
        else:

            raise RuntimeError(
                f"Variable {node.name.str_t} was not declared in this scope")
        return
    if isinstance(node, CUnary):
        resolve_expression(node.exp)
        return
    if isinstance(node, CBinary):
        resolve_expression(node.exp_left)
        resolve_expression(node.exp_right)
        return
    if isinstance(node, (CAssignment, CAssignmentCompound)):
        if not isinstance(node.exp_left, CVar):

            raise RuntimeError(
                f"Left expression {type(node.exp_left)} is an invalid lvalue")

        resolve_expression(node.exp_left)
        resolve_expression(node.exp_right)
        return
    if isinstance(node, CConditional):
        resolve_expression(node.condition)
        resolve_expression(node.exp_middle)
        resolve_expression(node.exp_right)
        return

    raise RuntimeError(
        "An error occurred in semantic analysis, not all nodes were visited")


cdef void resolve_variable(AST node):

    cdef int e
    cdef AST child_node
    cdef CBlockItem block_item
    for child_node, _, _ in ast_iter_child_nodes(node):
        if isinstance(child_node, CFunction):

            for e, block_item in enumerate(child_node.body):
                if isinstance(block_item, CS):
                    resolve_statement(block_item.statement)
                elif isinstance(block_item, CD):
                    resolve_declaration(block_item.declaration)
                else:

                    raise RuntimeError(
                        "An error occurred in semantic analysis, not all nodes were visited")

        else:
            resolve_variable(child_node)


cdef void semantic_analysis(AST c_ast):
    global variable_map
    variable_map = {}

    resolve_variable(c_ast)
