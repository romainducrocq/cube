from typing import List

from pycc.parser.__ast import AST, TIdentifier, TInt
from pycc.parser.__asm import *

__all__ = [
    'code_emission'
]


class CodeEmitterError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(CodeEmitterError, self).__init__(message)


class CodeEmitter:
    asm_code: List[str] = []

    def __init__(self):
        pass

    def emit(self, line: str, t=0) -> None:
        self.asm_code.append("    " * t + line + "\n")

    @staticmethod
    def expect_next(next_node, *expected_nodes: type) -> None:
        if not isinstance(next_node, expected_nodes):
            raise CodeEmitterError(
                f"Expected node of types ({expected_nodes}) but found \"{type(next_node)}\"")

    def emit_identifier(self, node: AST) -> str:
        """
        identifier ->
            $ identifier
        """
        self.expect_next(node, TIdentifier)
        return node.str_t

    def emit_int(self, node: AST) -> str:
        """
        int ->
            $ int
        """
        self.expect_next(node, TInt)
        return str(node.int_t)

    def emit_operand(self, node: AST) -> str:
        """
        Imm(int) ->
            $ $<int>
        Register ->
            $ %eax
        """
        self.expect_next(node, AsmOperand)
        if isinstance(node, AsmImm):
            value = self.emit_int(node.value)
            return "$" + value
        if isinstance(node, AsmRegister):
            register: str = "eax"
            return "%" + register

        raise CodeEmitterError(
            "An error occurred in code emission, not all nodes were visited")

    def emit_instruction(self, node: AST) -> None:
        """
        Mov(src, dst) ->
            $ movl <src>, <dst>
        Ret ->
            $ ret
        """
        self.expect_next(node, AsmInstruction)
        if isinstance(node, AsmMov):
            src: str = self.emit_operand(node.src)
            dst: str = self.emit_operand(node.dst)
            self.emit(f"movl {src}, {dst}", t=1)
        elif isinstance(node, AsmRet):
            self.emit("ret", t=1)
        else:

            raise CodeEmitterError(
                "An error occurred in code emission, not all nodes were visited")

    def emit_function_def(self, node: AST) -> None:
        """
        Function(name, instructions) ->
            $     .globl <name>
            $ <name>:
            $     <instructions>
        """
        self.expect_next(node, AsmFunctionDef)
        if isinstance(node, AsmFunction):
            name: str = self.emit_identifier(node.name)
            self.emit(f".globl {name}", t=1)
            self.emit(f"{name}:", t=0)
            for instruction in node.instructions:
                self.emit_instruction(instruction)
        else:

            raise CodeEmitterError(
                "An error occurred in code emission, not all nodes were visited")

    def emit_program(self, node: AST) -> None:
        """
        Program(function_definition) ->
            $ <function_definition>
            $     .section .note.GNU-stack,"",@progbits
        """
        self.expect_next(node, AST)
        if isinstance(node, AsmProgram):
            self.emit_function_def(node.function_def)
            self.emit(".section .note.GNU-stack,\"\",@progbits", t=1)
        else:

            raise CodeEmitterError(
                "An error occurred in code emission, not all nodes were visited")


def code_emission(asm_ast: AST) -> List[str]:

    code_emitter = CodeEmitter()

    code_emitter.emit_program(asm_ast)

    if not code_emitter.asm_code:
        raise CodeEmitterError(
            "An error occurred in code emission, ASM was not emitted")

    return code_emitter.asm_code
