import sys
import os

from typing import Tuple, List, Callable

from lexer import lexing
from parser import parsing
from assembly_generator import assembly_generation
from code_emitter import code_emission


ARG_LEX: str = "--lex"
ARG_PARSE: str = "--parse"
ARG_CODEGEN: str = "--codegen"
ARG_S: str = "-S"


def compiler(input_file: str, opt_stop: str, opt_s: bool) -> None:
    print(input_file)  # TODO rm
    print("-S", opt_s)  # TODO rm

    lexing(input_file)
    if opt_stop == ARG_LEX:
        return

    parsing()
    if opt_stop == ARG_PARSE:
        return

    assembly_generation()
    if opt_stop == ARG_CODEGEN:
        return

    code_emission()


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
