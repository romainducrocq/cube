from ccc.util_fopen cimport file_open_write, write_line, file_close_write
from ccc.assembly_asm_ast cimport *


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
    elif isinstance(node, AsmCx):
        return "cl"
    elif isinstance(node, AsmDx):
        return "dl"
    elif isinstance(node, AsmR10):
        return "r10b"
    elif isinstance(node, AsmR11):
        return "r11b"
    else:

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
    elif isinstance(node, AsmCx):
        return "ecx"
    elif isinstance(node, AsmDx):
        return "edx"
    elif isinstance(node, AsmR10):
        return "r10d"
    elif isinstance(node, AsmR11):
        return "r11d"
    else:

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
    elif isinstance(node, AsmNE):
        return "ne"
    elif isinstance(node, AsmL):
        return "l"
    elif isinstance(node, AsmLE):
        return "le"
    elif isinstance(node, AsmG):
        return "g"
    elif isinstance(node, AsmGE):
        return "ge"
    else:

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
    elif isinstance(node, AsmRegister):
        if byte == 1:
            operand = emit_register_1byte(node.reg)
        elif byte == 4:
            operand = emit_register_4byte(node.reg)
        else:

            raise RuntimeError(
                "An error occurred in code emission, unmanaged register byte size")

        return "%" + operand
    elif isinstance(node, AsmStack):
        operand = emit_int(node.value)
        return operand + "(%rbp)"
    else:

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
    elif isinstance(node, AsmSub):
        return "subl"
    elif isinstance(node, AsmMult):
        return "imull"
    elif isinstance(node, AsmBitAnd):
        return "andl"
    elif isinstance(node, AsmBitOr):
        return "orl"
    elif isinstance(node, AsmBitXor):
        return "xorl"
    elif isinstance(node, AsmBitShiftLeft):
        return "shll"
    elif isinstance(node, AsmBitShiftRight):
        return "shrl"
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef str emit_unary_op(AsmUnaryOp node):
    # Neg -> $ negl
    # Not -> $ notl
    if isinstance(node, AsmNeg):
        return "negl"
    elif isinstance(node, AsmNot):
        return "notl"
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef bint debug = False #
cdef list[str] print_code = [] #


cdef void emit(str line, int t = 0):
    line = " " * 4 * t + line

    if debug: #
        print_code.append(line) #
        return #
    write_line(line)


cdef void emit_ret_instructions(AsmRet node):
    emit("movq %rbp, %rsp", t=1)
    emit("popq %rbp", t=1)
    emit("ret", t=1)


cdef void emit_mov_instructions(AsmMov node):
    cdef str src = emit_operand(node.src, byte=4)
    cdef str dst = emit_operand(node.dst, byte=4)
    emit(f"movl {src}, {dst}", t=1)


cdef void emit_alloc_stack_instructions(AsmAllocStack node):
    cdef str value = emit_int(node.value)
    emit(f"subq ${value}, %rsp", t=1)


cdef void emit_label_instructions(AsmLabel node):
    cdef str label = emit_identifier(node.name)
    emit(f".L{label}:")


cdef void emit_cmp_instructions(AsmCmp node):
    cdef str src = emit_operand(node.src, byte=4)
    cdef str dst = emit_operand(node.dst, byte=4)
    emit(f"cmpl {src}, {dst}", t=1)


cdef void emit_jmp_instructions(AsmJmp node):
    cdef str label = emit_identifier(node.target)
    emit(f"jmp .L{label}", t=1)


cdef void emit_jmp_cc_instructions(AsmJmpCC node):
    cdef str cond_code = emit_condition_code(node.cond_code)
    cdef str label = emit_identifier(node.target)
    emit(f"j{cond_code} .L{label}", t=1)


cdef void emit_set_cc_instructions(AsmSetCC node):
    cdef str cond_code = emit_condition_code(node.cond_code)
    cdef str dst = emit_operand(node.dst, byte=1)
    emit(f"set{cond_code} {dst}", t=1)


cdef void emit_unary_instructions(AsmUnary node):
    cdef str unary_op = emit_unary_op(node.unary_op)
    cdef str dst = emit_operand(node.dst, byte=4)
    emit(f"{unary_op} {dst}", t=1)


cdef void emit_binary_instructions(AsmBinary node):
    cdef str binary_op = emit_binary_op(node.binary_op)
    cdef str src = emit_operand(node.src, byte=4)
    cdef str dst = emit_operand(node.dst, byte=4)
    emit(f"{binary_op} {src}, {dst}", t=1)


cdef void emit_idiv_instructions(AsmIdiv node):
    cdef str src = emit_operand(node.src, byte=4)
    emit(f"idivl {src}", t=1)


cdef void emit_cdq_instructions(AsmCdq node):
    emit("cdq", t=1)


cdef void emit_instructions(AsmInstruction node):
    # Ret                               -> $ movq %rbp, %rsp
    #                                      $ popq %rbp
    #                                      $ ret
    # Mov(src, dst)                     -> $ movl <src>, <dst>
    # AllocateStack(int)                -> $ subq $<int>, %rsp
    # Label(label)                      -> $ .L<label>:
    # Cmp(operand, operand)             -> $ cmpl <operand>, <operand>
    # Jmp(label)                        -> $ jmp .L<label>
    # JmpCC(cond_code, label)           -> $ j<cond_code> .L<label>
    # SetCC(cond_code, operand)         -> $ set<cond_code> <operand>
    # Unary(unary_operator, operand)    -> $ <unary_operator> <operand>
    # Binary(binary_operator, src, dst) -> $ <binary_operator> <src>, <dst>
    # Idiv(operand)                     -> $ idivl <operand>
    # Cdq                               -> $ cdq
    if isinstance(node, AsmRet):
        emit_ret_instructions(node)
    elif isinstance(node, AsmMov):
        emit_mov_instructions(node)
    elif isinstance(node, AsmAllocStack):
        emit_alloc_stack_instructions(node)
    elif isinstance(node, AsmLabel):
        emit_label_instructions(node)
    elif isinstance(node, AsmCmp):
        emit_cmp_instructions(node)
    elif isinstance(node, AsmJmp):
        emit_jmp_instructions(node)
    elif isinstance(node, AsmJmpCC):
        emit_jmp_cc_instructions(node)
    elif isinstance(node, AsmSetCC):
        emit_set_cc_instructions(node)
    elif isinstance(node, AsmUnary):
        emit_unary_instructions(node)
    elif isinstance(node, AsmBinary):
        emit_binary_instructions(node)
    elif isinstance(node, AsmIdiv):
        emit_idiv_instructions(node)
    elif isinstance(node, AsmCdq):
        emit_cdq_instructions(node)
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef void emit_list_instructions(list[AsmInstruction] list_node):
    cdef int instruction
    for instruction in range(len(list_node)):
        emit_instructions(list_node[instruction])


cdef void emit_function_def(AsmFunctionDef node):
    # Function(name, instructions) -> $     .globl <name>
    #                                 $ <name>:
    #                                 $     pushq %rbp
    #                                 $     movq %rsp, %rbp
    #                                 $     <instructions>
    cdef str name
    if isinstance(node, AsmFunction):
        name = emit_identifier(node.name)
        emit(f".globl {name}", t=1)
        emit(f"{name}:", t=0)
        emit("pushq %rbp", t=1)
        emit("movq %rsp, %rbp", t=1)
        emit_list_instructions(node.instructions)
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef void emit_program(AsmProgram node):
    # Program(function_definition) -> $ <function_definition>
    #                                 $     .section .note.GNU-stack,"",@progbits
    emit_function_def(node.function_def)
    emit(".section .note.GNU-stack,\"\",@progbits", t=1)


#
cdef list[str] code_emission_print(AsmProgram asm_ast): #
    global debug #
    global print_code #
    debug = True #
    print_code = [] #
#
    emit_program(asm_ast) #
#
    if not print_code: #
        raise RuntimeError( #
            "An error occurred in code emission, ASM was not emitted") #
#
    return print_code #
#

cdef void code_emission(AsmProgram asm_ast, str filename):

    file_open_write(filename)

    emit_program(asm_ast)

    file_close_write()
