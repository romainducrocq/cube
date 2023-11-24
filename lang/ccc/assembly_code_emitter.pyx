from ccc.assembly_asm_ast cimport *


cdef list[str] asm_code = []


cdef void emit(str line, int t = 0):

    asm_code.append(" " * 4 * t + line + "\n")


cdef str emit_identifier(TIdentifier node):
    # identifier -> $ identifier
    return node.str_t


cdef str emit_int(TInt node):
    # int -> $ int
    return str(node.int_t)


cdef str emit_register_1byte(AsmReg node):
    # Reg(AX)  -> $ %al
    # Reg(CX)  -> $ %cl
    # Reg(DX)  -> $ %dl
    # Reg(R10) -> $ %r10b
    # Reg(R11) -> $ %r11b
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

    raise RuntimeError(
        "An error occurred in code emission, not all nodes were visited")


cdef str emit_register_4byte(AsmReg node):
    # Reg(AX)  -> $ %eax
    # Reg(CX)  -> $ %ecx
    # Reg(DX)  -> $ %edx
    # Reg(R10) -> $ %r10d
    # Reg(R11) -> $ %r11d
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

    raise RuntimeError(
        "An error occurred in code emission, not all nodes were visited")


cdef str emit_condition_code(AsmCondCode node):
    # E  -> $ e
    # NE -> $ ne
    # L  -> $ l
    # LE -> $ le
    # G  -> $ g
    # GE -> $ ge
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

    raise RuntimeError(
        "An error occurred in code emission, not all nodes were visited")


cdef str emit_operand(AsmOperand node, int byte = 4):
    # Imm(int)      -> $ $<int>
    # Register(reg) -> $ %reg
    # Stack(int)    -> $ <int>(%rbp)
    cdef str operand
    if isinstance(node, AsmImm):
        operand = emit_int(node.value)
        return "$" + operand
    if isinstance(node, AsmRegister):
        if byte == 1:
            operand = emit_register_1byte(node.reg)
        elif byte == 4:
            operand = emit_register_4byte(node.reg)
        else:

            raise RuntimeError(
                "An error occurred in code emission, unmanaged register byte size")

        return "%" + operand
    if isinstance(node, AsmStack):
        operand = emit_int(node.value)
        return operand + "(%rbp)"

    raise RuntimeError(
        "An error occurred in code emission, not all nodes were visited")


cdef str emit_binary_op(AsmBinaryOp node):
    # Add           -> $ addl
    # Sub           -> $ subl
    # Mult          -> $ imull
    # BitAnd        -> $ andl
    # BitOr         -> $ orl
    # BitXor        -> $ xorl
    # BitShiftLeft  -> $ shll
    # BitShiftRight -> $ shrl
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

    raise RuntimeError(
        "An error occurred in code emission, not all nodes were visited")


cdef str emit_unary_op(AsmUnaryOp node):
    # Neg -> $ negl
    # Not -> $ notl
    if isinstance(node, AsmNeg):
        return "negl"
    if isinstance(node, AsmNot):
        return "notl"

    raise RuntimeError(
        "An error occurred in code emission, not all nodes were visited")


# def emit_instruction(node: AST) -> None:
#     """
#     Mov(src, dst) ->
#         $ movl <src>, <dst>
#     Ret ->
#         $ movq %rbp, %rsp
#         $ popq %rbp
#         $ ret
#     Unary(unary_operator, operand) ->
#         $ <unary_operator> <operand>
#     Binary(binary_operator, src, dst) ->
#         $ <binary_operator> <src>, <dst>
#     Idiv(operand) ->
#         $ idivl <operand>
#     Cdq ->
#         $ cdq
#     AllocateStack(int) ->
#         $ subq $<int>, %rsp
#     Cmp(operand, operand) ->
#         $ cmpl <operand>, <operand>
#     Jmp(label) ->
#         $ jmp .L<label>
#     JmpCC(cond_code, label) ->
#         $ j<cond_code> .L<label>
#     SetCC(cond_code, operand) ->
#         $ set<cond_code> <operand>
#     Label(label) ->
#         $ .L<label>:
#     """
#     expect_next(node, AsmInstruction)
#     if isinstance(node, AsmMov):
#         src: str = emit_operand(node.src, byte=4)
#         dst: str = emit_operand(node.dst, byte=4)
#         emit(f"movl {src}, {dst}", t=1)
#     elif isinstance(node, AsmRet):
#         emit("movq %rbp, %rsp", t=1)
#         emit("popq %rbp", t=1)
#         emit("ret", t=1)
#     elif isinstance(node, AsmUnary):
#         unary_op: str = emit_unary_op(node.unary_op)
#         dst: str = emit_operand(node.dst, byte=4)
#         emit(f"{unary_op} {dst}", t=1)
#     elif isinstance(node, AsmBinary):
#         binary_op: str = emit_binary_op(node.binary_op)
#         src: str = emit_operand(node.src, byte=4)
#         dst: str = emit_operand(node.dst, byte=4)
#         emit(f"{binary_op} {src}, {dst}", t=1)
#     elif isinstance(node, AsmIdiv):
#         src: str = emit_operand(node.src, byte=4)
#         emit(f"idivl {src}", t=1)
#     elif isinstance(node, AsmCdq):
#         emit("cdq", t=1)
#     elif isinstance(node, AsmAllocStack):
#         value: str = emit_int(node.value)
#         emit(f"subq ${value}, %rsp", t=1)
#     elif isinstance(node, AsmCmp):
#         src: str = emit_operand(node.src, byte=4)
#         dst: str = emit_operand(node.dst, byte=4)
#         emit(f"cmpl {src}, {dst}", t=1)
#     elif isinstance(node, AsmJmp):
#         label: str = emit_identifier(node.target)
#         emit(f"jmp .L{label}", t=1)
#     elif isinstance(node, AsmJmpCC):
#         cond_code: str = emit_condition_code(node.cond_code)
#         label: str = emit_identifier(node.target)
#         emit(f"j{cond_code} .L{label}", t=1)
#     elif isinstance(node, AsmSetCC):
#         cond_code: str = emit_condition_code(node.cond_code)
#         dst: str = emit_operand(node.dst, byte=1)
#         emit(f"set{cond_code} {dst}", t=1)
#     elif isinstance(node, AsmLabel):
#         label: str = emit_identifier(node.name)
#         emit(f".L{label}:")
#     else:
#
#         raise CodeEmitterError(
#             "An error occurred in code emission, not all nodes were visited")
#
#
# def emit_function_def(node: AST) -> None:
#     """
#     Function(name, instructions) ->
#         $     .globl <name>
#         $ <name>:
#         $     pushq %rbp
#         $     movq %rsp, %rbp
#         $     <instructions>
#     """
#     expect_next(node, AsmFunctionDef)
#     if isinstance(node, AsmFunction):
#         name: str = emit_identifier(node.name)
#         emit(f".globl {name}", t=1)
#         emit(f"{name}:", t=0)
#         emit("pushq %rbp", t=1)
#         emit("movq %rsp, %rbp", t=1)
#         for instruction in node.instructions:
#             emit_instruction(instruction)
#     else:
#
#         raise CodeEmitterError(
#             "An error occurred in code emission, not all nodes were visited")
#
#
# def emit_program(node: AST) -> None:
#     """
#     Program(function_definition) ->
#         $ <function_definition>
#         $     .section .note.GNU-stack,"",@progbits
#     """
#     expect_next(node, AST)
#     if isinstance(node, AsmProgram):
#         emit_function_def(node.function_def)
#         emit(".section .note.GNU-stack,\"\",@progbits", t=1)
#     else:
#
#         raise CodeEmitterError(
#             "An error occurred in code emission, not all nodes were visited")
#
#
# def code_emission(asm_ast: AST) -> List[str]:
#     global asm_code
#
#     asm_code = []
#     emit_program(asm_ast)
#
#     if not asm_code:
#         raise CodeEmitterError(
#             "An error occurred in code emission, ASM was not emitted")
#
#     return asm_code

cdef list[str] code_emission(AST asm_ast):
    return []
