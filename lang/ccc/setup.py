from os import path, getcwd
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

file_in = open(f"{path.dirname(getcwd())}/build/package_name.txt", "r", encoding="utf-8")
PACKAGE_NAME = file_in.read()
file_in.close()

file_in = open(f"{path.dirname(getcwd())}/build/python_version.txt", "r", encoding="utf-8")
PYTHON_VERSION = file_in.read()
file_in.close()

ext_modules = [
    Extension(f"{PACKAGE_NAME}.main_compiler",  ["./main_compiler.pyx"]),
    Extension(f"{PACKAGE_NAME}.util_ast", ["./util_ast.pyx"]),
    Extension(f"{PACKAGE_NAME}.util_fopen", ["./util_fopen.pyx"]),
    Extension(f"{PACKAGE_NAME}.util_iota_enum",  ["./util_iota_enum.pyx"]),
    Extension(f"{PACKAGE_NAME}.lexer_lexer", ["./lexer_lexer.pyx"]),
    Extension(f"{PACKAGE_NAME}.parser_c_ast",  ["./parser_c_ast.pyx"]),
    Extension(f"{PACKAGE_NAME}.parser_parser",  ["./parser_parser.pyx"]),
    Extension(f"{PACKAGE_NAME}.parser_precedence", ["./parser_precedence.pyx"]),
    Extension(f"{PACKAGE_NAME}.semantic_name", ["./semantic_name.pyx"]),
    Extension(f"{PACKAGE_NAME}.semantic_identifier_resolver", ["./semantic_identifier_resolver.pyx"]),
    Extension(f"{PACKAGE_NAME}.semantic_loop_annotater", ["./semantic_loop_annotater.pyx"]),
    Extension(f"{PACKAGE_NAME}.semantic_type_checker", ["./semantic_type_checker.pyx"]),
    # Extension(f"{PACKAGE_NAME}.intermediate_tac_ast", ["./intermediate_tac_ast.pyx"]),
    # Extension(f"{PACKAGE_NAME}.intermediate_three_address_generator", ["./intermediate_three_address_generator.pyx"]),
    # Extension(f"{PACKAGE_NAME}.assembly_asm_ast", ["./assembly_asm_ast.pyx"]),
    # Extension(f"{PACKAGE_NAME}.assembly_assembly_generator", ["./assembly_assembly_generator.pyx"]),
    # Extension(f"{PACKAGE_NAME}.assembly_code_emitter", ["./assembly_code_emitter.pyx"]),
    # Extension(f"{PACKAGE_NAME}.assembly_register", ["./assembly_register.pyx"]),
    # Extension(f"{PACKAGE_NAME}.assembly_stack", ["./assembly_stack.pyx"]),
]

for ext_module in ext_modules:
    ext_module.cython_directives = {"language_level": "3"}

setup(
    name=f"{PACKAGE_NAME}",
    version="0.1",
    license="MIT",
    python_requires=f"=={PYTHON_VERSION}",
    cmdclass={"build_ext": build_ext},
    ext_modules=ext_modules
)
