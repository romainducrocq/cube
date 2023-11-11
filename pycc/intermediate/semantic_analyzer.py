from typing import Dict

from pycc.util.__ast import *
from pycc.parser.c_ast import *
from pycc.intermediate.name import NameManager

__all__ = [
    'semantic_analysis'
]


class SemanticAnalyzerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(SemanticAnalyzerError, self).__init__(message)


class SemanticAnalyzer:
    variable_map: Dict[str, str] = {}

    def __init__(self):
        pass

    @staticmethod
    def expect_next(next_node, *expected_nodes: type) -> None:
        if not isinstance(next_node, expected_nodes):
            raise SemanticAnalyzerError(
                f"Expected node in types {expected_nodes} but found \"{type(next_node)}\"")

    def resolve_statement(self, node: AST) -> None:
        self.expect_next(node, CStatement)
        if isinstance(node, (CReturn, CExpression)):
            self.resolve_expression(node.exp)
        elif isinstance(node, CNull):
            pass
        else:

            raise SemanticAnalyzerError(
                "An error occurred in semantic analysis, not all nodes were visited")

    def resolve_declaration(self, node: AST) -> None:
        self.expect_next(node, CDeclaration)
        if isinstance(node, CDecl):
            if node.name.str_t in self.variable_map:

                raise SemanticAnalyzerError(
                    f"Variable {node.name.str_t} was already declared in this scope")

            name: TIdentifier = NameManager.resolve_variable_identifier(node.name)
            self.variable_map[node.name.str_t] = name.str_t
            node.name = name
            if node.init:
                self.resolve_expression(node.init)
        else:

            raise SemanticAnalyzerError(
                "An error occurred in semantic analysis, not all nodes were visited")

    def resolve_expression(self, node: AST) -> None:
        self.expect_next(node, CExp)
        if isinstance(node, CConstant):
            pass
        elif isinstance(node, CVar):
            if node.name.str_t in self.variable_map:
                name: TIdentifier = TIdentifier(self.variable_map[node.name.str_t])
                node.name = name
            else:

                raise SemanticAnalyzerError(
                    f"Variable {node.name.str_t} was not declared in this scope")

        elif isinstance(node, CUnary):
            self.resolve_expression(node.exp)
        elif isinstance(node, CBinary):
            self.resolve_expression(node.exp_left)
            self.resolve_expression(node.exp_right)
        elif isinstance(node, CAssignment):
            if not isinstance(node.exp_left, CVar):

                raise SemanticAnalyzerError(
                    f"Left expression {type(node.exp_left)} is an invalid lvalue")

            self.resolve_expression(node.exp_left)
            self.resolve_expression(node.exp_right)

        else:

            raise SemanticAnalyzerError(
                "An error occurred in semantic analysis, not all nodes were visited")

    def resolve_variable(self, node: AST) -> None:

        for child_node, _, _ in AST.iter_child_nodes(node):
            if isinstance(child_node, CFunction):

                for e, block_item in enumerate(child_node.body):
                    if isinstance(block_item, CS):
                        self.resolve_statement(block_item.statement)
                    elif isinstance(block_item, CD):
                        self.resolve_declaration(block_item.declaration)
                    else:

                        raise SemanticAnalyzerError(
                            "An error occurred in semantic analysis, not all nodes were visited")

            else:
                self.resolve_variable(child_node)


def semantic_analysis(c_ast: AST) -> None:

    semantic_analyzer = SemanticAnalyzer()

    semantic_analyzer.resolve_variable(c_ast)
