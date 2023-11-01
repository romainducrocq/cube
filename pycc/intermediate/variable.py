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


counter: int = 0

VARIABLE_NAME: Dict[type, str] = {
    CConstant: "constant",
    CUnary: "unary",
    CBinary: "binary"
}


class VariableManager:

    def __init__(self):
        pass

    @staticmethod
    def represent_variable_identifier(node: AST) -> TIdentifier:
        global counter

        try:
            name = VARIABLE_NAME[type(node)]
        except KeyError:

            raise VariableManagerError(
                f"An error occurred in variable management, unmanaged type {type(node)}")

        counter += 1
        name: str = f"{name}.{counter - 1}"

        return TIdentifier(name)
