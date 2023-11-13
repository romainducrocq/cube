from typing import Dict

from ccc.util.__ast import *
from ccc.parser.c_ast import *

__all__ = [
    'resolve_variable_identifier',
    'represent_label_identifier',
    'represent_variable_identifier'
]


class NameManagerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(NameManagerError, self).__init__(message)


label_counter: int = 0
variable_counter: int = 0

VARIABLE_NAME: Dict[type, str] = {
    CVar: "var",
    CConstant: "constant",
    CUnary: "unary",
    CBinary: "binary"
}


def resolve_variable_identifier(variable: TIdentifier) -> TIdentifier:
    global variable_counter

    variable_counter += 1
    name: str = f"{variable.str_t}.{variable_counter - 1}"

    return TIdentifier(name)


def represent_label_identifier(label: str) -> TIdentifier:
    global label_counter

    label_counter += 1
    name: str = f"{label}.{label_counter - 1}"

    return TIdentifier(name)


def represent_variable_identifier(node: AST) -> TIdentifier:
    global variable_counter

    try:
        variable: str = VARIABLE_NAME[type(node)]
    except KeyError:

        raise NameManagerError(
            f"An error occurred in name management, unmanaged type {type(node)}")

    variable_counter += 1
    name: str = f"{variable}.{variable_counter - 1}"

    return TIdentifier(name)
