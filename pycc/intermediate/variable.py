from typing import Optional

from pycc.util.__ast import AST, TIdentifier
from pycc.parser.c_ast import CConstant

__all__ = [
    'VariableManager'
]

DEFAULT: str = "tmp"


class VariableManager:

    counter: int = 0
    last: str = ""

    def __init__(self):
        pass

    def name_variable(self, node: Optional[AST]) -> TIdentifier:
        name: str = DEFAULT

        if isinstance(node, CConstant):
            name = "const"

        self.counter += 1
        name: str = f"{name}.{self.counter - 1}"

        self.last = name
        return TIdentifier(name)

    def get_last(self) -> TIdentifier:
        return TIdentifier(self.last)

    def represent_variable_identifier(self, node: Optional[AST], last: bool) -> TIdentifier:
        if last:
            return self.get_last()

        return self.name_variable(node)
