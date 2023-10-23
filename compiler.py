import sys
import os

from typing import Tuple, List, Callable

from helper import debug
from lexer import lexing
from parser import parsing
from assembly_generator import assembly_generation
from code_emitter import code_emission


ARG_LEX: str = "--lex"
ARG_PARSE: str = "--parse"
ARG_CODEGEN: str = "--codegen"
ARG_S: str = "-S"


def compiler(input_file: str, opt_stop: str, opt_s: bool) -> None:
    debug(input_file)  # TODO rm
    debug(f"-S: {opt_s}")  # TODO rm

    print("Start lexing...")
    token_kinds: List[int] = lexing(input_file)
    print("Exit lexing: OK")
    if opt_stop == ARG_LEX:
        return

    print("Start parsing...")
    parsing()
    print("Exit parsing: OK")
    if opt_stop == ARG_PARSE:
        return

    print("Start assembly generation...")
    assembly_generation()
    print("Exit assembly generation: OK")
    if opt_stop == ARG_CODEGEN:
        return

    print("Start code emission...")
    code_emission()
    print("Exit code emission: OK")


def arg_parse(argv: List[str]) -> Tuple[str, str, bool]:

    shift: Callable[[], str] = \
        lambda: "" if not argv else argv.pop(0)

    _ = shift()
    assert argv, "ERROR: No file was provided..."

    input_file = shift()
    assert os.path.exists(input_file), "ERROR: File does not exist..."

    opt_stop: str = ""
    if ARG_CODEGEN in argv:
        opt_stop = ARG_CODEGEN
    elif ARG_PARSE in argv:
        opt_stop = ARG_PARSE
    elif ARG_LEX in argv:
        opt_stop = ARG_LEX

    opt_s: bool = ARG_S in argv

    return input_file, opt_stop, opt_s


if __name__ == "__main__":

    compiler(*arg_parse(sys.argv))

    exit(0)
