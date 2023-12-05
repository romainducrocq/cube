from ccc.util_ast cimport AST, ast_pretty_string

from ccc.lexer_lexer cimport lexing, Token
from ccc.parser_c_ast cimport CProgram
from ccc.parser_parser cimport parsing

from ccc.semantic_variable_resolver cimport analyze_semantic

from ccc.intermediate_tac_ast cimport TacProgram
from ccc.intermediate_three_address_generator cimport three_address_code_representation

from ccc.assembly_asm_ast cimport AsmProgram
from ccc.assembly_assembly_generator cimport assembly_generation
from ccc.assembly_code_emitter cimport code_emission
from ccc.assembly_code_emitter cimport code_emission_print #


cdef bint VERBOSE = False


cdef void verbose(str string = "", str end="\n"):
    if VERBOSE:
        print(string, end=end)

#
cdef void debug_tokens(list[Token] tokens): #
    cdef int token #
    for token in range(len(tokens)): #
        verbose(str(token) + ': ("' + tokens[token].token + #
              '", ' + str(tokens[token].token_kind) + ')') #
#
#
cdef void debug_ast(AST ast): #
    verbose(ast_pretty_string(ast)) #
#
#
cdef void debug_code(list[str] code): #
    cdef int code_line #
    for code_line in range(len(code)): #
        verbose(code[code_line]) #
#

cdef void do_compile(str filename, int opt_code, int opt_s_code):

    verbose("-- Lexing ... ", end="")
    cdef list[Token] tokens = lexing(filename)
    verbose("OK")
    if opt_code == 255:
        debug_tokens(tokens) #
        return

    verbose("-- Parsing ... ", end="")
    cdef CProgram c_ast = parsing(tokens)
    verbose("OK")
    if opt_code == 254:
        debug_ast(c_ast) #
        return

    verbose("-- Semantic analysis ... ", end="")
    analyze_semantic(c_ast)
    verbose("OK")
    if opt_code == 253:
        debug_ast(c_ast) #
        return

    verbose("-- TAC representation ... ", end="")
    cdef TacProgram tac_ast = three_address_code_representation(c_ast)
    verbose("OK")
    if opt_code == 252:
        debug_ast(tac_ast) #
        return

    verbose("-- Assembly generation ... ", end="")
    cdef AsmProgram asm_ast = assembly_generation(tac_ast)
    verbose("OK")
    if opt_code == 251:
        debug_ast(asm_ast) #
        return

    verbose("-- Code emission ... ", end="")
    if opt_code == 250: #
        debug_code(code_emission_print(asm_ast)) #
        verbose("OK") #
        return #

    filename = f"{filename.rsplit('.', 1)[0]}.s"
    code_emission(asm_ast, filename)
    verbose("OK")


cdef str shift_args(list[str] argv):
    if argv:
        return argv.pop(0)
    return ""


cdef tuple[str, int, int] arg_parse(list[str] argv):

    _ = shift_args(argv)
    cdef str arg

    arg = shift_args(argv)
    if not arg:
        raise RuntimeError(
            f"No option code passed in args[0]")
    cdef int opt_code = int(arg)

    arg = shift_args(argv)
    if not arg:
        raise RuntimeError(
            f"No file name passed in args[1]")
    cdef str filename = arg

    return filename, opt_code, 0


cdef void entry(list[str] args):
    global VERBOSE

    cdef str filename
    cdef int opt_code
    cdef int opt_s_code
    filename, opt_code, opt_s_code = arg_parse(args)
    if opt_code > 0:
        VERBOSE = True

    do_compile(filename, opt_code, opt_s_code)


cdef public int main_c(int argc, char **argv):
    cdef int i
    cdef list[str] args = []
    for i in range(argc):
        args.append(str(argv[i].decode("UTF-8")))

    entry(args)


cpdef void main_py():
    import sys

    entry(sys.argv)
