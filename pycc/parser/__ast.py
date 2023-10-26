from typing import Any, List
from dataclasses import dataclass

__all__ = [
    'AST',
    'CIdentifier',
    'CInt',
    'CExp',
    'CConstant',
    'CStatement',
    'CReturn',
    'CFunctionDef',
    'CFunction',
    'CProgram'
]


class AST:
    """ AST node """
    @staticmethod
    def fields(cls):
        return [attr for attr in dir(cls)
                if not attr.startswith("__") and not callable(getattr(cls, attr))]

    def pretty_string(self) -> str:
        string = ""

        def _pretty_string(kind: str = "<AST> ", node: Any = None, indent: int = 0) -> None:
            nonlocal string
            if not node:
                node = self

            string += str(' ' * indent + kind + type(node).__name__ + ':' + '\n')
            indent += 4

            def _pretty_string_child(_child_kind: str, _child_node: Any):
                nonlocal string
                if '__dict__' in dir(_child_node):
                    _pretty_string(_child_kind, _child_node, indent)
                else:
                    string += str(' ' * indent + _child_kind + type(str(_child_node)).__name__ + ': '
                                  + str(_child_node) + '\n')

            for child_kind, child_node in node.__dict__.items():
                if isinstance(child_node, list):
                    string += str(' ' * indent + "<" + child_kind + "[" + str(len(child_node)) + "]> " + '\n')
                    indent += 4

                    for e, list_node in enumerate(child_node):
                        for list_child_node in list_node.__dict__.values():
                            _pretty_string_child(f'{e}: ', list_child_node)
                    indent -= 4

                else:
                    _pretty_string_child("<" + child_kind + "> ", child_node)

        _pretty_string()
        return string[:-1]


@dataclass
class CIdentifier:
    """ identifier str_t """
    str_t: str = None


@dataclass
class CInt:
    """ int int_t """
    int_t: int = None


class CExp:
    """
    exp = Constant(int value)
    """
    pass


@dataclass
class CConstant(CExp):
    """ Constant(int value) """
    value: CInt = None


class CStatement:
    """
    statement = Return(exp)
    """
    pass


@dataclass
class CReturn(CStatement):
    """ Return(exp) """
    exp: CExp = None


class CFunctionDef:
    """
    function_definition = Function(identifier name, statement body)
    """
    pass


@dataclass
class CFunction(CFunctionDef):
    """ Function(identifier name, statement body) """
    name: CIdentifier = None
    body: CStatement = None


@dataclass
class CProgram(AST):
    """
    program = Program(function_definition)
    """
    function_def: CFunctionDef = None

