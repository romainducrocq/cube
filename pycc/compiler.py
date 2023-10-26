import sys
import os

from typing import Tuple, List, Generator

from pycc.util.iota_enum import IotaEnum
from pycc.parser.__ast import AST
from pycc.parser.lexer import lexing, Token
from pycc.parser.parser import parsing
from pycc.parser.assembly_generator import assembly_generation
from pycc.parser.code_emitter import code_emission

DEBUG: bool = True


class CompilerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__()


OPT: IotaEnum = IotaEnum(
    "none",
    "lex",
    "parse",
    "codegen",
    "S"
)


def debug(string: str = "", end="\n") -> None:
    if DEBUG:
        print(string, end=end)


def compiler(filename: str, opt_exit: int, opt_s: int) -> None:

    print("Start lexing...")
    lexing(filename)
    tokens: Generator[Token, None, None] = lexing(filename)
    print("Exit lexing: OK")
    if opt_exit == OPT.lex:
        for token in list(tokens):
            debug(str(token))
        return

    print("Start parsing...")
    c_ast: AST = parsing(tokens)
    print("Exit parsing: OK")
    if opt_exit == OPT.parse:
        debug(c_ast.pretty_string())
        return

    print("Start assembly generation...")
    assembly_generation()
    print("Exit assembly generation: OK")
    if opt_exit == OPT.codegen:
        return

    print("Start code emission...")
    code_emission()
    print("Exit code emission: OK")


def arg_parse(argv: List[str]) -> Tuple[str, int, int]:

    class ArgParseError(RuntimeError):
        def __init__(self, message: str) -> None:
            self.message = message
            super().__init__()

    def shift() -> str:
        return "" if not argv else argv.pop(0)

    _ = shift()
    if not argv:
        raise ArgParseError(
            f"No file was provided in args")

    filename = shift()
    if not os.path.exists(filename):
        raise ArgParseError(
            f"File {filename} does not exist")

    opt_exit: int = OPT.none
    if "--codegen" in argv:
        opt_exit = OPT.codegen
    elif "--parse" in argv:
        opt_exit = OPT.parse
    elif "--lex" in argv:
        opt_exit = OPT.lex

    opt_s: int = OPT.none
    if "-S" in argv:
        opt_s = OPT.S

    return filename, opt_exit, opt_s


if __name__ == "__main__":

    compiler(*arg_parse(sys.argv))

    exit(0)
