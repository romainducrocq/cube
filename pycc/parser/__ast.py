from typing import Optional
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

        def _pretty_string(kind: str = "AST", node: Optional[AST] = None, indent: int = 0) -> None:
            nonlocal string
            if not node:
                node = self

            string += str(' ' * indent + "<" + kind + "> " + type(node).__name__ + ':' + '\n')
            indent += 4
            for c_kind, child in node.__dict__.items():
                if '__dict__' in dir(child):
                    _pretty_string(c_kind, child, indent)
                else:
                    string += str(' ' * indent + "<" + c_kind + "> " + type(str(child)).__name__ + ': '
                                  + str(child) + '\n')

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

