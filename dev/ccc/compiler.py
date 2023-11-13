import platform
import sys
import os

from ccc.util.iota_enum cimport IotaEnum
# from ccc.util.__ast import AST
# from ccc.parser.lexer import lexing, Token
# from ccc.parser.parser import parsing
# from ccc.intermediate.semantic_analyzer import semantic_analysis
# from ccc.intermediate.three_address_generator import three_address_code_representation
# from ccc.assembly.assembly_generator import assembly_generation
# from ccc.assembly.code_emitter import code_emission

__all__ = [
    'main'
]


cdef bint DEBUG = True


class CompilerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(CompilerError, self).__init__(message)


cdef IotaEnum OPT
OPT = IotaEnum((
    "none",
    "lex",
    "parse",
    "validate",
    "tacky",
    "codegen",
    "codeemit",
    "S"
))


cpdef void debug(str string = "", str end="\n"):
    if DEBUG:
        print(string, end=end)


cpdef void compile(str filename, int opt_exit, int opt_s):
    debug(filename)
    debug(str(opt_exit))
    debug(str(opt_s))

    # print("-- Start lexing...")
    # tokens: List[Token] = lexing(filename)
    # print("-- Exit lexing: OK")
    # if opt_exit == OPT.lex:
    #     for e, token in enumerate(tokens):
    #         debug(str(e) + ': ("' + token.token + '", ' + str(token.token_kind) + ')')
    #     return

    # print("-- Start parsing...")
    # c_ast: AST = parsing(tokens)
    # print("-- Exit parsing: OK")
    # if opt_exit == OPT.parse:
    #     debug(c_ast.pretty_string())
    #     return

    # print("-- Start semantic analysis...")
    # semantic_analysis(c_ast)
    # print("-- Exit semantic analysis: OK")
    # if opt_exit == OPT.validate:
    #     debug(c_ast.pretty_string())
    #     return
    #
    # print("-- Start tac representation...")
    # tac_ast: AST = three_address_code_representation(c_ast)
    # print("-- Exit tac representation: OK")
    # if opt_exit == OPT.tacky:
    #     debug(tac_ast.pretty_string())
    #     return
    #
    # print("-- Start assembly generation...")
    # asm_ast: AST = assembly_generation(tac_ast)
    # print("-- Exit assembly generation: OK")
    # if opt_exit == OPT.codegen:
    #     debug(asm_ast.pretty_string())
    #     return
    #
    # print("-- Start code emission...")
    # asm_code: List[str] = code_emission(asm_ast)
    # print("-- Exit code emission: OK")
    # if opt_exit == OPT.codeemit:
    #     for code_line in asm_code:
    #         debug(code_line[:-1])
    #     return
    #
    # filename_out: str = f"{filename.rsplit('.', 1)[0]}.s"
    # with open(filename_out, "w", encoding="utf-8") as output_file:
    #     output_file.writelines(asm_code)


cpdef tuple[str, int, int] arg_parse(list[str] argv):
    cdef str filename
    cdef int opt_exit, opt_s

    _ = "" if not argv else argv.pop(0)
    if not argv:
        raise CompilerError(
            f"No file was provided in args")

    filename = "" if not argv else argv.pop(0)
    if not os.path.exists(filename):
        raise CompilerError(
            f"File {filename} does not exist")

    opt_exit = OPT.get('none')
    if "--codeemit" in argv:
        opt_exit = OPT.get('codeemit')
    elif "--codegen" in argv:
        opt_exit = OPT.get('codegen')
    elif "--tacky" in argv:
        opt_exit = OPT.get('tacky')
    elif "--validate" in argv:
        opt_exit = OPT.get('validate')
    elif "--parse" in argv:
        opt_exit = OPT.get('parse')
    elif "--lex" in argv:
        opt_exit = OPT.get('lex')

    opt_s = OPT.get('none')
    if "-S" in argv:
        opt_s = OPT.get('S')

    return filename, opt_exit, opt_s


cpdef void main():

    if (int(platform.python_version().split('.')[0]) < 3 or
            (int(platform.python_version().split('.')[0]) >= 3 and
             int(platform.python_version().split('.')[1]) < 9)):
        raise CompilerError(
            f"Python version too old, >= 3.9 required but {platform.python_version()} used")

    compile(*arg_parse(sys.argv))

    exit(0)
