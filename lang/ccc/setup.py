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
    Extension(f"{PACKAGE_NAME}.parser_c_ast",  ["./parser_c_ast.pyx"]),
    Extension(f"{PACKAGE_NAME}.parser_lexer",  ["./parser_lexer.pyx"]),
    Extension(f"{PACKAGE_NAME}.parser_parser",  ["./parser_parser.pyx"]),
    Extension(f"{PACKAGE_NAME}.parser_precedence", ["./parser_precedence.pyx"]),
    Extension(f"{PACKAGE_NAME}.intermediate_name", ["./intermediate_name.pyx"]),
    Extension(f"{PACKAGE_NAME}.intermediate_semantic_analyzer", ["./intermediate_semantic_analyzer.pyx"]),
    Extension(f"{PACKAGE_NAME}.intermediate_tac_ast", ["./intermediate_tac_ast.pyx"]),
    Extension(f"{PACKAGE_NAME}.intermediate_three_address_generator", ["./intermediate_three_address_generator.pyx"]),

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
