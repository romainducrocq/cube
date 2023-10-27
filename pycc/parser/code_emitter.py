from typing import List

from pycc.parser.__ast import AST
from pycc.parser.__asm import *

__all__ = [
    'code_emission'
]


class CodeEmitterError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(CodeEmitterError, self).__init__(message)


class CodeEmitter:
    asm_code: str = None

    def __init__(self):
        pass

    def emit_program(self, node: AST) -> None:
        # TODO
        self.asm_code = """\
    .globl main
main:
    movl $2, %eax
    ret

   .section .note.GNU-stack,"",@progbits"""

def code_emission(asm_ast: AST) -> str:

    code_emitter = CodeEmitter()

    code_emitter.emit_program(asm_ast)

    if not code_emitter.asm_code:
        raise CodeEmitterError(
            "An error occurred in code emission, ASM was not emitted")

    return code_emitter.asm_code
