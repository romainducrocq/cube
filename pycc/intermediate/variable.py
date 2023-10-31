from pycc.util.__ast import AST, TIdentifier
from pycc.parser.c_ast import CConstant, CUnary

__all__ = [
    'VariableManager'
]


class VariableManager:

    counter: int = 0

    def __init__(self):
        pass

    def represent_variable_identifier(self, node: AST) -> TIdentifier:

        name: str = "tmp"
        if isinstance(node, CConstant):
            name = "const"
        elif isinstance(node, CUnary):
            name = "unary"

        self.counter += 1
        name: str = f"{name}.{self.counter - 1}"

        return TIdentifier(name)
