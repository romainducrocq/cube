from typing import Any, Tuple, Generator

__all__ = [
    'AST',
    'TIdentifier',
    'TInt',
    'ast_iter_child_nodes',
    'ast_set_child_node'
]


class AST:
    """
    AST node
    """
    _fields = ()

    def pretty_string(self) -> str:
        string = ""

        def _pretty_string(kind: str = '<AST> ', node: Any = None, indent: int = 0) -> None:
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
                    string += str(' ' * indent + _child_kind + type(_child_node).__name__ + ': '
                                  + str(_child_node) + '\n')

            for child_kind, child_node in node.__dict__.items():
                if isinstance(child_node, list):
                    string += str(' ' * indent + '<' + child_kind + '> List(' + str(len(child_node)) + '):' + '\n')
                    indent += 4

                    for e, list_node in enumerate(child_node):
                        _pretty_string_child('[' + str(e) + '] ', list_node)

                    indent -= 4

                else:
                    _pretty_string_child('<' + child_kind + '> ', child_node)

        _pretty_string()
        return string[:-1]


class TIdentifier(AST):
    """ identifier str_t """
    str_t: str = None
    _fields = ('str_t',)

    def __init__(self, str_t: str):
        self.str_t = str_t


class TInt(AST):
    """ int int_t """
    int_t: int = None

    _fields = ('int_t',)

    def __init__(self, int_t: int):
        self.int_t = int_t


def ast_iter_fields(node: AST) -> Generator[Tuple[Any, str], None, None]:
    for field, name in [(getattr(node, _field), _field) for _field in node._fields]:
        yield field, name


def ast_iter_child_nodes(node: AST) -> Generator[Tuple[Any, str, int], None, None]:
    for field, name in ast_iter_fields(node):
        if isinstance(field, AST):
            yield field, name, -1
        elif isinstance(field, list):
            for e, item in enumerate(field):
                if isinstance(item, AST):
                    yield item, name, e


def ast_set_child_node(field: Any, name: str, index: int, set_node: Any) -> None:
    if isinstance(field, AST):
        setattr(field, name, set_node)
    elif isinstance(getattr(field, name), list):
        getattr(field, name)[index] = set_node