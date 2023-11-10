from pycc.util.__ast import *
from pycc.parser.c_ast import *

__all__ = [
    'semantic_analysis'
]


class SemanticAnalyzerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(SemanticAnalyzerError, self).__init__(message)


class SemanticAnalyzer:
    c_ast: AST = None

    def __init__(self, c_ast: AST):
        self.c_ast = c_ast

    def resolve_variable(self) -> None:
        pass


def semantic_analysis(c_ast: AST) -> AST:

    semantic_analyzer = SemanticAnalyzer(c_ast)

    semantic_analyzer.resolve_variable()

    return semantic_analyzer.c_ast
