import sys
import os

from typing import Tuple, List, Callable, Generator

from util import AttributeDict, debug
from lexer import lexing, Token
from parser import parsing
from assembly_generator import assembly_generation
from code_emitter import code_emission


class CompilerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__()


OPT: AttributeDict[str, str] = AttributeDict({
    "lex": "--lex",
    "parse": "--parse",
    "codegen": "--codegen",
    "S": "-S"
})


def compiler(filename: str, opt_stop: str, opt_s: bool) -> None:
    debug(filename)  # TODO rm
    debug(f"-S: {opt_s}")  # TODO rm

    print("Start lexing...")
    lexing(filename)
    tokens: Generator[Token, None, None] = lexing(filename)
    # for token in list(tokens):  # TODO rm
    #     debug(f"{token.token}, {token.token_kind}")
    print("Exit lexing: OK")
    if opt_stop == OPT.lex:
        return

    print("Start parsing...")
    parsing(tokens)
    print("Exit parsing: OK")
    if opt_stop == OPT.parse:
        return

    print("Start assembly generation...")
    assembly_generation()
    print("Exit assembly generation: OK")
    if opt_stop == OPT.codegen:
        return

    print("Start code emission...")
    code_emission()
    print("Exit code emission: OK")


def arg_parse(argv: List[str]) -> Tuple[str, str, bool]:

    shift: Callable[[], str] = \
        lambda: "" if not argv else argv.pop(0)

    _ = shift()
    if not argv:
        raise CompilerError(
            f"No file was provided in args")

    filename = shift()
    if not os.path.exists(filename):
        raise CompilerError(
            f"File {filename} does not exist")

    opt_stop: str = ""
    if OPT.codegen in argv:
        opt_stop = OPT.codegen
    elif OPT.parse in argv:
        opt_stop = OPT.parse
    elif OPT.lex in argv:
        opt_stop = OPT.lex

    opt_s: bool = OPT.S in argv

    return filename, opt_stop, opt_s


if __name__ == "__main__":

    compiler(*arg_parse(sys.argv))

    exit(0)
