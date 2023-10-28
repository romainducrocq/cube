from typing import Any, Tuple, Generator
from dataclasses import dataclass

__all__ = [
    'AST',
    'TIdentifier',
    'TInt',
    'CUnaryOp',
    'CComplement',
    'CNegate',
    'CExp',
    'CConstant',
    'CUnary',
    'CStatement',
    'CReturn',
    'CFunctionDef',
    'CFunction',
    'CProgram'
]


class AST:
    """
    AST node
    """
    @staticmethod
    def iter_fields(node: Any) -> Generator[Tuple[str, Any], None, None]:
        for name, field in [(attr, getattr(node, attr)) for attr in dir(node)
                            if not attr.startswith("__")]:
            if not callable(field) and isinstance(field, (AST, list)):
                yield name, field

    @staticmethod
    def iter_child_nodes(node: Any) -> Generator[Any, None, None]:
        for name, field in AST.iter_fields(node):
            if isinstance(field, AST):
                yield field
            elif isinstance(field, list):
                for item in field:
                    if isinstance(item, AST):
                        yield item

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

                    e: int = 0
                    for list_node in child_node:
                        for item_child_node in list_node.__dict__.values():
                            _pretty_string_child(f'{e}: ', item_child_node)
                            e+=1

                    indent -= 4

                else:
                    _pretty_string_child("<" + child_kind + "> ", child_node)

        _pretty_string()
        return string[:-1]


@dataclass
class TIdentifier(AST):
    """ identifier str_t """
    str_t: str = None


@dataclass
class TInt(AST):
    """ int int_t """
    int_t: int = None


class CUnaryOp(AST):
    """
    unary_operator = Complement
                   | Negate
    """
    pass


class CComplement(CUnaryOp):
    """ Complement """
    pass


class CNegate(CUnaryOp):
    """ Negate """
    pass


class CExp(AST):
    """
    exp = Constant(int value)
        | Unary(unary_operator, exp)
    """
    pass


@dataclass
class CConstant(CExp):
    """ Constant(int value) """
    value: TInt = None


@dataclass
class CUnary(CExp):
    """ Unary(unary_operator, exp) """
    unary_op: CUnaryOp = None
    exp: CExp = None


class CStatement(AST):
    """
    statement = Return(exp)
    """
    pass


@dataclass
class CReturn(CStatement):
    """ Return(exp) """
    exp: CExp = None


class CFunctionDef(AST):
    """
    function_definition = Function(identifier name, statement body)
    """
    pass


@dataclass
class CFunction(CFunctionDef):
    """ Function(identifier name, statement body) """
    name: TIdentifier = None
    body: CStatement = None


@dataclass
class CProgram(AST):
    """ AST = Program(function_definition) """
    function_def: CFunctionDef = None
