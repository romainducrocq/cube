from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [
    Extension("ccc.__compiler",  ["./__compiler.pyx"]),
    Extension("ccc.util_ast", ["./util_ast.pyx"]),
    Extension("ccc.util_fopen", ["./util_fopen.pyx"]),
    Extension("ccc.util_iota_enum",  ["./util_iota_enum.pyx"]),
    Extension("ccc.parser_c_ast",  ["./parser_c_ast.pyx"]),
    Extension("ccc.parser_lexer",  ["./parser_lexer.pyx"]),
    Extension("ccc.parser_parser",  ["./parser_parser.pyx"]),
    Extension("ccc.parser_precedence", ["./parser_precedence.pyx"]),
    Extension("ccc.intermediate_name", ["./intermediate_name.pyx"]),
]

for ext_module in ext_modules:
    ext_module.cython_directives = {"language_level": "3"}

setup(
    name="ccc",
    version="0.1",
    license="MIT",
    python_requires="==3.9",
    cmdclass={"build_ext": build_ext},
    ext_modules=ext_modules
)
