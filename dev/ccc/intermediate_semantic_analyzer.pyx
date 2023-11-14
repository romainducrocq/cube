from ccc.util_ast cimport ast_iter_child_nodes
from ccc.parser_c_ast cimport (AST, TIdentifier, CFunction, CBlockItem,
                               CD, CDeclaration, CDecl, CS, CStatement, CReturn, CExpression, CNull,
                               CExp, CVar, CConstant, CUnary, CBinary, CAssignment, CAssignmentCompound)
from ccc.intermediate_name cimport resolve_variable_identifier


class SemanticAnalyzerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(SemanticAnalyzerError, self).__init__(message)


cdef dict[str, str] variable_map = {}


cpdef void expect_next(AST next_node, tuple[type, ...] expected_nodes):
    if not isinstance(next_node, expected_nodes):
        raise SemanticAnalyzerError(
            f"Expected node in types {expected_nodes} but found \"{type(next_node)}\"")


cpdef void resolve_statement(AST node):
    expect_next(node, (CStatement,))
    if isinstance(node, (CReturn, CExpression)):
        resolve_expression(node.exp)
        return
    if isinstance(node, CNull):
        return

    raise SemanticAnalyzerError(
        "An error occurred in semantic analysis, not all nodes were visited")


cpdef void resolve_declaration(AST node):
    global variable_map

    expect_next(node, (CDeclaration,))
    cdef TIdentifier name
    if isinstance(node, CDecl):
        if node.name.str_t in variable_map:

            raise SemanticAnalyzerError(
                f"Variable {node.name.str_t} was already declared in this scope")

        name = resolve_variable_identifier(node.name)
        variable_map[node.name.str_t] = name.str_t
        node.name = name
        if node.init:
            resolve_expression(node.init)
        return

    raise SemanticAnalyzerError(
        "An error occurred in semantic analysis, not all nodes were visited")


cpdef void resolve_expression(AST node):
    expect_next(node, (CExp,))
    if isinstance(node, CConstant):
        return
    cdef TIdentifier name
    if isinstance(node, CVar):
        if node.name.str_t in variable_map:
            name = TIdentifier(variable_map[node.name.str_t])
            node.name = name
        else:

            raise SemanticAnalyzerError(
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

            raise SemanticAnalyzerError(
                f"Left expression {type(node.exp_left)} is an invalid lvalue")

        resolve_expression(node.exp_left)
        resolve_expression(node.exp_right)
        return

    raise SemanticAnalyzerError(
        "An error occurred in semantic analysis, not all nodes were visited")


cpdef void resolve_variable(AST node):

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

                    raise SemanticAnalyzerError(
                        "An error occurred in semantic analysis, not all nodes were visited")

        else:
            resolve_variable(child_node)


cpdef void semantic_analysis(AST c_ast):
    global variable_map
    variable_map = {}

    resolve_variable(c_ast)
