from dataclasses import dataclass

__all__ = [
    'AST',
    'Expr',
    'Constant',
    'Statement',
    'Return',
    'Function'
]


class AST:
    """ AST node """
    @staticmethod  # TODO keep ?
    def fields(cls):
        return [attr for attr in dir(cls)
                if not attr.startswith("__") and not callable(getattr(cls, attr))]

    def pretty_string(self) -> str:
        string = ""

        def _pretty_string(node: AST = None, indent: int = 0) -> None:
            nonlocal string
            if not node:
                node = self

            string += str(' ' * indent + type(node).__name__ + ':' + '\n')
            indent += 4
            for kind, child in node.__dict__.items():
                if '__dict__' in dir(child):
                    _pretty_string(child, indent)
                else:
                    string += str(' ' * indent + kind + ': ' + str(child) + '\n')

        _pretty_string()
        return string[:-1]


class Expr(AST):
    """
    expr = Constant(constant value)
    """
    pass


@dataclass
class Constant(Expr):
    """ Constant(constant value) """
    value: int = None


class Statement(AST):
    """
    stmt = Return(expr? value)
    """
    pass


@dataclass
class Return(Statement):
    """ Return(expr? value) """
    expr: Expr = None


@dataclass
class Function(AST):
    """
    stmt = Function(identifier name, statement body)
    """
    name: str = None
    body: Statement = None

