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
    @staticmethod
    def fields(cls):
        return [attr for attr in dir(cls)
                if not attr.startswith("__") and not callable(getattr(cls, attr))]


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

