from typing import List

from pycc.util.__ast import *
from pycc.assembly.asm_ast import *

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

    def emit_register_1byte(self, node: AST) -> str:
        """
        Reg(AX) ->
            $ %al
        Reg(CX) ->
            $ %cl
        Reg(DX) ->
            $ %dl
        Reg(R10) ->
            $ %r10b
        Reg(R11) ->
            $ %r11b
        """
        self.expect_next(node, AsmReg)
        if isinstance(node, AsmAx):
            return "al"
        if isinstance(node, AsmCx):
            return "cl"
        if isinstance(node, AsmDx):
            return "dl"
        if isinstance(node, AsmR10):
            return "r10b"
        if isinstance(node, AsmR11):
            return "r11b"

        raise CodeEmitterError(
            "An error occurred in code emission, not all nodes were visited")

    def emit_register_4byte(self, node: AST) -> str:
        """
        Reg(AX) ->
            $ %eax
        Reg(CX) ->
            $ %ecx
        Reg(DX) ->
            $ %edx
        Reg(R10) ->
            $ %r10d
        Reg(R11) ->
            $ %r11d
        """
        self.expect_next(node, AsmReg)
        if isinstance(node, AsmAx):
            return "eax"
        if isinstance(node, AsmCx):
            return "ecx"
        if isinstance(node, AsmDx):
            return "edx"
        if isinstance(node, AsmR10):
            return "r10d"
        if isinstance(node, AsmR11):
            return "r11d"

        raise CodeEmitterError(
            "An error occurred in code emission, not all nodes were visited")

    def emit_condition_code(self, node: AST) -> str:
        """
        E ->
            $ e
        NE ->
            $ ne
        L ->
            $ l
        LE ->
            $ le
        G ->
            $ g
        GE ->
            $ ge
        """
        self.expect_next(node, AsmCondCode)
        if isinstance(node, AsmE):
            return "e"
        if isinstance(node, AsmNE):
            return "ne"
        if isinstance(node, AsmL):
            return "l"
        if isinstance(node, AsmLE):
            return "le"
        if isinstance(node, AsmG):
            return "g"
        if isinstance(node, AsmGE):
            return "ge"

        raise CodeEmitterError(
            "An error occurred in code emission, not all nodes were visited")

    def emit_operand(self, node: AST, byte: int = 4) -> str:
        """
        Imm(int) ->
            $ $<int>
        Register(reg) ->
            $ %reg
        Stack(int) ->
            $ <int>(%rbp)
        """
        self.expect_next(node, AsmOperand)
        if isinstance(node, AsmImm):
            value: str = self.emit_int(node.value)
            return "$" + value
        if isinstance(node, AsmRegister):
            if byte == 1:
                register: str = self.emit_register_1byte(node.register)
            elif byte == 4:
                register: str = self.emit_register_4byte(node.register)
            else:

                raise CodeEmitterError(
                    "An error occurred in code emission, unmanaged register byte size")

            return "%" + register
        if isinstance(node, AsmStack):
            value: str = self.emit_int(node.value)
            return value + "(%rbp)"

        raise CodeEmitterError(
            "An error occurred in code emission, not all nodes were visited")

    def emit_binary_op(self, node: AST) -> str:
        """
        Add ->
            $ addl
        Sub ->
            $ subl
        Mult ->
            $ imull
        BitAnd ->
            $ andl
        BitOr ->
            $ orl
        BitXor ->
            $ xorl
        BitShiftLeft ->
            $ shll
        BitShiftRight ->
            $ shrl
        """
        self.expect_next(node, AsmBinaryOp)
        if isinstance(node, AsmAdd):
            return "addl"
        if isinstance(node, AsmSub):
            return "subl"
        if isinstance(node, AsmMult):
            return "imull"
        if isinstance(node, AsmBitAnd):
            return "andl"
        if isinstance(node, AsmBitOr):
            return "orl"
        if isinstance(node, AsmBitXor):
            return "xorl"
        if isinstance(node, AsmBitShiftLeft):
            return "shll"
        if isinstance(node, AsmBitShiftRight):
            return "shrl"

        raise CodeEmitterError(
            "An error occurred in code emission, not all nodes were visited")

    def emit_unary_op(self, node: AST) -> str:
        """
        Neg ->
            $ negl
        Not ->
            $ notl
        """
        self.expect_next(node, AsmUnaryOp)
        if isinstance(node, AsmNeg):
            return "negl"
        if isinstance(node, AsmNot):
            return "notl"

        raise CodeEmitterError(
            "An error occurred in code emission, not all nodes were visited")

    def emit_instruction(self, node: AST) -> None:
        """
        Mov(src, dst) ->
            $ movl <src>, <dst>
        Ret ->
            $ movq %rbp, %rsp
            $ popq %rbp
            $ ret
        Unary(unary_operator, operand) ->
            $ <unary_operator> <operand>
        Binary(binary_operator, src, dst) ->
            $ <binary_operator> <src>, <dst>
        Idiv(operand) ->
            $ idivl <operand>
        Cdq ->
            $ cdq
        AllocateStack(int) ->
            $ subq $<int>, %rsp
        Cmp(operand, operand) ->
            $ cmpl <operand>, <operand>
        Jmp(label) ->
            $ jmp .L<label>
        JmpCC(cond_code, label) ->
            $ j<cond_code> .L<label>
        SetCC(cond_code, operand) ->
            $ set<cond_code> <operand>
        Label(label) ->
            $ .L<label>:
        """
        self.expect_next(node, AsmInstruction)
        if isinstance(node, AsmMov):
            src: str = self.emit_operand(node.src, byte=4)
            dst: str = self.emit_operand(node.dst, byte=4)
            self.emit(f"movl {src}, {dst}", t=1)
        elif isinstance(node, AsmRet):
            self.emit("movq %rbp, %rsp", t=1)
            self.emit("popq %rbp", t=1)
            self.emit("ret", t=1)
        elif isinstance(node, AsmUnary):
            unary_op: str = self.emit_unary_op(node.unary_op)
            dst: str = self.emit_operand(node.dst, byte=4)
            self.emit(f"{unary_op} {dst}", t=1)
        elif isinstance(node, AsmBinary):
            binary_op: str = self.emit_binary_op(node.binary_op)
            src: str = self.emit_operand(node.src, byte=4)
            dst: str = self.emit_operand(node.dst, byte=4)
            self.emit(f"{binary_op} {src}, {dst}", t=1)
        elif isinstance(node, AsmIdiv):
            src: str = self.emit_operand(node.src, byte=4)
            self.emit(f"idivl {src}", t=1)
        elif isinstance(node, AsmCdq):
            self.emit("cdq", t=1)
        elif isinstance(node, AsmAllocStack):
            value: str = self.emit_int(node.value)
            self.emit(f"subq ${value}, %rsp", t=1)
        elif isinstance(node, AsmCmp):
            src: str = self.emit_operand(node.src, byte=4)
            dst: str = self.emit_operand(node.dst, byte=4)
            self.emit(f"cmpl {src}, {dst}", t=1)
        elif isinstance(node, AsmJmp):
            label: str = self.emit_identifier(node.target)
            self.emit(f"jmp .L{label}", t=1)
        elif isinstance(node, AsmJmpCC):
            cond_code: str = self.emit_condition_code(node.cond_code)
            label: str = self.emit_identifier(node.target)
            self.emit(f"j{cond_code} .L{label}", t=1)
        elif isinstance(node, AsmSetCC):
            cond_code: str = self.emit_condition_code(node.cond_code)
            dst: str = self.emit_operand(node.dst, byte=1)
            self.emit(f"set{cond_code} {dst}")
        elif isinstance(node, AsmLabel):
            label: str = self.emit_identifier(node.name)
            self.emit(f".L{label}:")
        else:

            raise CodeEmitterError(
                "An error occurred in code emission, not all nodes were visited")

    def emit_function_def(self, node: AST) -> None:
        """
        Function(name, instructions) ->
            $     .globl <name>
            $ <name>:
            $     pushq %rbp
            $     movq %rsp, %rbp
            $     <instructions>
        """
        self.expect_next(node, AsmFunctionDef)
        if isinstance(node, AsmFunction):
            name: str = self.emit_identifier(node.name)
            self.emit(f".globl {name}", t=1)
            self.emit(f"{name}:", t=0)
            self.emit("pushq %rbp", t=1)
            self.emit("movq %rsp, %rbp", t=1)
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
