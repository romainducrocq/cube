from pycc.util.__ast import AST, TIdentifier
from pycc.parser.c_ast import CConstant

__all__ = [
    'var_identifier'
]


var_counter: int = 0


def var_identifier(node: AST) -> TIdentifier:
    global var_counter

    var_str: str = "tmp"
    if isinstance(node, CConstant):
        var_str = "const"

    var_counter += 1
    name: str = f"{var_str}.{var_counter - 1}"
    return TIdentifier(name)
