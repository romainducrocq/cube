from ccc.util_iota_enum cimport IotaEnum
from ccc.util_ast cimport AST, ast_pretty_string
from ccc.parser_lexer cimport lexing, Token
from ccc.parser_parser cimport parsing
from ccc.intermediate_semantic_analyzer cimport semantic_analysis
from ccc.intermediate_three_address_generator cimport three_address_code_representation
# from ccc.assembly.assembly_generator import assembly_generation
# from ccc.assembly.code_emitter import code_emission


cdef bint DEBUG = True


class CompilerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(CompilerError, self).__init__(message)


cdef IotaEnum OPT = IotaEnum((
    "none",
    "--lex",
    "--parse",
    "--validate",
    "--tacky",
    "--codegen",
    "--codeemit",
    "-S"
))


cdef void debug(str string = "", str end="\n"):
    if DEBUG:
        print(string, end=end)


cdef void compile(str filename, int opt_exit, int opt_s):

    print("-- Start lexer...")
    cdef list[Token] tokens = lexing(filename)
    print("-- Exit lexer: OK")
    cdef int e
    cdef Token token
    if opt_exit == OPT.get('--lex'):
        for e, token in enumerate(tokens):
            debug(str(e) + ': ("' + token.token + '", ' +
                  str(token.token_kind) + ')')
        return

    print("-- Start parser...")
    cdef AST c_ast = parsing(tokens)
    print("-- Exit parser: OK")
    if opt_exit == OPT.get('--parse'):
        debug(ast_pretty_string(c_ast))
        return

    print("-- Start semantic analysis...")
    semantic_analysis(c_ast)
    print("-- Exit semantic analysis: OK")
    if opt_exit == OPT.get('--validate'):
        debug(ast_pretty_string(c_ast))
        return

    print("-- Start tac representation...")
    cdef AST tac_ast = three_address_code_representation(c_ast)
    print("-- Exit tac representation: OK")
    if opt_exit == OPT.get('--tacky'):
        debug(ast_pretty_string(tac_ast))
        return

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


cdef str shift_args(list[str] argv):
    if argv:
        return argv.pop(0)
    return ""


cdef tuple[str, int, int] arg_parse(list[str] argv):

    _ = shift_args(argv)

    cdef str arg
    cdef list[str] argv_opts = []
    while True:
        arg = shift_args(argv)
        if not arg in OPT.iter():
            break
        argv_opts.append(arg)

    cdef int opt_exit = OPT.get('none')
    if "--codeemit" in argv_opts:
        opt_exit = OPT.get('--codeemit')
    elif "--codegen" in argv_opts:
        opt_exit = OPT.get('--codegen')
    elif "--tacky" in argv_opts:
        opt_exit = OPT.get('--tacky')
    elif "--validate" in argv_opts:
        opt_exit = OPT.get('--validate')
    elif "--parse" in argv_opts:
        opt_exit = OPT.get('--parse')
    elif "--lex" in argv_opts:
        opt_exit = OPT.get('--lex')

    cdef int opt_s = OPT.get('none')
    if "-S" in argv_opts:
        opt_s = OPT.get('-S')

    cdef str filename = arg

    if not filename:
        raise CompilerError(
            f"No file was provided in args")

    return filename, opt_exit, opt_s


cdef void entry(list[str] args):

    cdef str filename
    cdef int opt_exit
    cdef int opt_s

    filename, opt_exit, opt_s = arg_parse(args)
    compile(filename, opt_exit, opt_s)


cdef public int main_c(int argc, char **argv):
    cdef int i
    cdef list[str] args = []
    for i in range(argc):
        args.append(str(argv[i].decode("UTF-8")))

    entry(args)


cpdef void main_py():
    import sys

    entry(sys.argv)
