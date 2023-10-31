from typing import Dict

from pycc.util.__ast import *
from pycc.parser.c_ast import *

__all__ = [
    'VariableManager'
]


class VariableManagerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(VariableManagerError, self).__init__(message)


VARIABLE_NAME: Dict[type, str] = {
    CConstant: "constant",
    CUnary: "unary"
}


class VariableManager:

    counter: int = 0

    def __init__(self):
        pass

    def represent_variable_identifier(self, node: AST) -> TIdentifier:

        try:
            name = VARIABLE_NAME[type(node)]
        except KeyError:

            raise VariableManagerError(
                f"An error occurred in variable management, unmanaged type {type(node)}")

        self.counter += 1
        name: str = f"{name}.{self.counter - 1}"

        return TIdentifier(name)
