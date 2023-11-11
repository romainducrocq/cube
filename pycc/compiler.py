import platform
import sys
import os

from typing import Tuple, List

from pycc.util.iota_enum import IotaEnum
from pycc.util.__ast import AST
from pycc.parser.lexer import lexing, Token
from pycc.parser.parser import parsing
from pycc.intermediate.semantic_analyzer import semantic_analysis
from pycc.intermediate.three_address_generator import three_address_code_representation
from pycc.assembly.assembly_generator import assembly_generation
from pycc.assembly.code_emitter import code_emission

__all__ = [
    'main'
]


DEBUG: bool = True


class CompilerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(CompilerError, self).__init__(message)


OPT: IotaEnum = IotaEnum(
    "none",
    "lex",
    "parse",
    "validate",
    "tacky",
    "codegen",
    "codeemit",
    "S"
)


def debug(string: str = "", end="\n") -> None:
    if DEBUG:
        print(string, end=end)


def compile(filename: str, opt_exit: int, opt_s: int) -> None:

    print("-- Start lexing...")
    tokens: List[Token] = lexing(filename)
    print("-- Exit lexing: OK")
    if opt_exit == OPT.lex:
        for token in tokens:
            debug(str(token))
        return

    print("-- Start parsing...")
    c_ast: AST = parsing(tokens)
    print("-- Exit parsing: OK")
    if opt_exit == OPT.parse:
        debug(c_ast.pretty_string())
        return

    print("-- Start semantic analysis...")
    semantic_analysis(c_ast)
    print("-- Exit semantic analysis: OK")
    if opt_exit == OPT.validate:
        debug(c_ast.pretty_string())
        return

    print("-- Start tac representation...")
    tac_ast: AST = three_address_code_representation(c_ast)
    print("-- Exit tac representation: OK")
    if opt_exit == OPT.tacky:
        debug(tac_ast.pretty_string())
        return

    print("-- Start assembly generation...")
    asm_ast: AST = assembly_generation(tac_ast)
    print("-- Exit assembly generation: OK")
    if opt_exit == OPT.codegen:
        debug(asm_ast.pretty_string())
        return

    print("-- Start code emission...")
    asm_code: List[str] = code_emission(asm_ast)
    print("-- Exit code emission: OK")
    if opt_exit == OPT.codeemit:
        for code_line in asm_code:
            debug(code_line[:-1])
        return

    filename_out: str = f"{filename.rsplit('.', 1)[0]}.s"
    with open(filename_out, "w", encoding="utf-8") as output_file:
        output_file.writelines(asm_code)

    # debug # TODO rm
    if False:
        import shutil
        if not os.path.exists(f"{os.getcwd()}/.temp/"):
            os.makedirs(f"{os.getcwd()}/.temp/")
        shutil.copyfile(filename, f"{os.getcwd()}/.temp/{filename.rsplit('/', 1)[1]}")
        shutil.copyfile(filename_out, f"{os.getcwd()}/.temp/{filename_out.rsplit('/', 1)[1]}")


def arg_parse(argv: List[str]) -> Tuple[str, int, int]:

    class ArgParseError(RuntimeError):
        def __init__(self, message: str) -> None:
            self.message = message
            super(ArgParseError, self).__init__(message)

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
    if "--codeemit" in argv:
        opt_exit = OPT.codeemit
    elif "--codegen" in argv:
        opt_exit = OPT.codegen
    elif "--tacky" in argv:
        opt_exit = OPT.tacky
    elif "--validate" in argv:
        opt_exit = OPT.validate
    elif "--parse" in argv:
        opt_exit = OPT.parse
    elif "--lex" in argv:
        opt_exit = OPT.lex

    opt_s: int = OPT.none
    if "-S" in argv:
        opt_s = OPT.S

    return filename, opt_exit, opt_s


def main() -> None:

    if (int(platform.python_version().split('.')[0]) < 3 or
            (int(platform.python_version().split('.')[0]) >= 3 and
             int(platform.python_version().split('.')[1]) < 9)):
        raise CompilerError(
            f"Python version too old, >= 3.9 required but {platform.python_version()} used")

    compile(*arg_parse(sys.argv))

    exit(0)
