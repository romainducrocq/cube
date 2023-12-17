from ccc.util_ctypes cimport int32
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
    # Reg(DX)  -> $ %dl
    # Reg(CX)  -> $ %cl
    # Reg(DI)  -> $ %dil
    # Reg(SI)  -> $ %sil
    # Reg(R8)  -> $ %r8b
    # Reg(R9)  -> $ %r9b
    # Reg(R10) -> $ %r10b
    # Reg(R11) -> $ %r11b
    if isinstance(node, AsmAx):
        return "al"
    elif isinstance(node, AsmDx):
        return "dl"
    elif isinstance(node, AsmCx):
        return "cl"
    elif isinstance(node, AsmDi):
        return "dil"
    elif isinstance(node, AsmSi):
        return "sil"
    elif isinstance(node, AsmR8):
        return "r8b"
    elif isinstance(node, AsmR9):
        return "r9b"
    elif isinstance(node, AsmR10):
        return "r10b"
    elif isinstance(node, AsmR11):
        return "r11b"
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef str emit_register_4byte(AsmReg node):
    # Reg(AX)  -> $ %eax
    # Reg(DX)  -> $ %edx
    # Reg(CX)  -> $ %ecx
    # Reg(DI)  -> $ %edi
    # Reg(SI)  -> $ %esi
    # Reg(R8)  -> $ %r8d
    # Reg(R9)  -> $ %r9d
    # Reg(R10) -> $ %r10d
    # Reg(R11) -> $ %r11d
    if isinstance(node, AsmAx):
        return "eax"
    elif isinstance(node, AsmDx):
        return "edx"
    elif isinstance(node, AsmCx):
        return "ecx"
    elif isinstance(node, AsmDi):
        return "edi"
    elif isinstance(node, AsmSi):
        return "esi"
    elif isinstance(node, AsmR8):
        return "r8d"
    elif isinstance(node, AsmR9):
        return "r9d"
    elif isinstance(node, AsmR10):
        return "r10d"
    elif isinstance(node, AsmR11):
        return "r11d"
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef str emit_register_8byte(AsmReg node):
    # Reg(AX)  -> $ %rax
    # Reg(DX)  -> $ %rdx
    # Reg(CX)  -> $ %rcx
    # Reg(DI)  -> $ %rdi
    # Reg(SI)  -> $ %rsi
    # Reg(R8)  -> $ %r8
    # Reg(R9)  -> $ %r9
    # Reg(R10) -> $ %r10
    # Reg(R11) -> $ %r11
    if isinstance(node, AsmAx):
        return "rax"
    elif isinstance(node, AsmDx):
        return "rdx"
    elif isinstance(node, AsmCx):
        return "rcx"
    elif isinstance(node, AsmDi):
        return "rdi"
    elif isinstance(node, AsmSi):
        return "rsi"
    elif isinstance(node, AsmR8):
        return "r8"
    elif isinstance(node, AsmR9):
        return "r9"
    elif isinstance(node, AsmR10):
        return "r10"
    elif isinstance(node, AsmR11):
        return "r11"
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


cdef str emit_operand(AsmOperand node, int32 byte):
    # Imm(int)         -> $ $<int>
    # Register(reg)    -> $ %reg
    # Stack(int)       -> $ <int>(%rbp)
    # Data(identifier) -> $ <identifier>(%rip)
    cdef str operand
    if isinstance(node, AsmImm):
        operand = emit_int(node.value)
        return "$" + operand
    elif isinstance(node, AsmRegister):
        if byte == 1:
            operand = emit_register_1byte(node.reg)
        elif byte == 4:
            operand = emit_register_4byte(node.reg)
        elif byte == 8:
            operand = emit_register_8byte(node.reg)
        else:

            raise RuntimeError(
                "An error occurred in code emission, unmanaged register byte size")

        return "%" + operand
    elif isinstance(node, AsmStack):
        operand = emit_int(node.value)
        return operand + "(%rbp)"
    elif isinstance(node, AsmData):
        operand = emit_identifier(node.name)
        return operand + "(%rip)"
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


cdef void emit(str line, int32 indent):
    line = " " * 4 * indent + line

    if debug: #
        print_code.append(line) #
        return #
    write_line(line)


cdef void emit_ret_instructions(AsmRet node):
    emit("movq %rbp, %rsp", 1)
    emit("popq %rbp", 1)
    emit("ret", 1)


cdef void emit_mov_instructions(AsmMov node):
    cdef str src = emit_operand(node.src, 4)
    cdef str dst = emit_operand(node.dst, 4)
    emit(f"movl {src}, {dst}", 1)


cdef void emit_alloc_stack_instructions(AsmAllocStack node):
    cdef str value = emit_int(node.value)
    emit(f"subq ${value}, %rsp", 1)


cdef void emit_dealloc_stack_instructions(AsmDeallocateStack node):
    cdef str value = emit_int(node.value)
    emit(f"addq ${value}, %rsp", 1)


cdef void emit_push_instructions(AsmPush node):
    cdef str src = emit_operand(node.src, 8)
    emit(f"pushq {src}", 1)


cdef void emit_call_instructions(AsmCall node):
    cdef str label = emit_identifier(node.name)
    emit(f"call {label}@PLT", 1)


cdef void emit_label_instructions(AsmLabel node):
    cdef str label = emit_identifier(node.name)
    emit(f".L{label}:", 0)


cdef void emit_cmp_instructions(AsmCmp node):
    cdef str src = emit_operand(node.src, 4)
    cdef str dst = emit_operand(node.dst, 4)
    emit(f"cmpl {src}, {dst}", 1)


cdef void emit_jmp_instructions(AsmJmp node):
    cdef str label = emit_identifier(node.target)
    emit(f"jmp .L{label}", 1)


cdef void emit_jmp_cc_instructions(AsmJmpCC node):
    cdef str cond_code = emit_condition_code(node.cond_code)
    cdef str label = emit_identifier(node.target)
    emit(f"j{cond_code} .L{label}", 1)


cdef void emit_set_cc_instructions(AsmSetCC node):
    cdef str cond_code = emit_condition_code(node.cond_code)
    cdef str dst = emit_operand(node.dst, 1)
    emit(f"set{cond_code} {dst}", 1)


cdef void emit_unary_instructions(AsmUnary node):
    cdef str unary_op = emit_unary_op(node.unary_op)
    cdef str dst = emit_operand(node.dst, 4)
    emit(f"{unary_op} {dst}", 1)


cdef void emit_binary_instructions(AsmBinary node):
    cdef str binary_op = emit_binary_op(node.binary_op)
    cdef str src = emit_operand(node.src, 4)
    cdef str dst = emit_operand(node.dst, 4)
    emit(f"{binary_op} {src}, {dst}", 1)


cdef void emit_idiv_instructions(AsmIdiv node):
    cdef str src = emit_operand(node.src, 4)
    emit(f"idivl {src}", 1)


cdef void emit_cdq_instructions(AsmCdq node):
    emit("cdq", 1)


cdef void emit_instructions(AsmInstruction node):
    # Ret                               -> $ movq %rbp, %rsp
    #                                      $ popq %rbp
    #                                      $ ret
    # Mov(src, dst)                     -> $ movl <src>, <dst>
    # AllocateStack(int)                -> $ subq $<int>, %rsp
    # DeallocateStack(int)              -> $ addq $<int>, %rsp
    # Push(operand)                     -> $ pushq <operand>
    # Call(label)                       -> $ call <label>@PLT
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
    elif isinstance(node, AsmDeallocateStack):
        emit_dealloc_stack_instructions(node)
    elif isinstance(node, AsmPush):
        emit_push_instructions(node)
    elif isinstance(node, AsmCall):
        emit_call_instructions(node)
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
    cdef Py_ssize_t instruction
    for instruction in range(len(list_node)):
        emit_instructions(list_node[instruction])


cdef void emit_alignment_directive_top_level():
    # $ .align 4
    emit(f".align 4", 1)


cdef void emit_global_directive_top_level(bint is_global, str name):
    # if is_global: -> $ .globl <identifier>
    if is_global:
        emit(f".globl {name}", 1)


cdef void emit_function_top_level(AsmFunction node):
    # Function(name, global, instructions) -> $     <global-directive>
    #                                         $     .text
    #                                         $ <name>:
    #                                         $     pushq %rbp
    #                                         $     movq %rsp, %rbp
    #                                         $     <instructions>
    cdef str name = emit_identifier(node.name)
    emit_global_directive_top_level(node.is_global, name)
    emit(".text", 1)
    emit(f"{name}:", 0)
    emit("pushq %rbp", 1)
    emit("movq %rsp, %rbp", 1)
    emit_list_instructions(node.instructions)


cdef void emit_data_static_variable_top_level(AsmStaticVariable node):
    # StaticVariable(name, global, init) initialized to non-zero value -> $     <global-directive>
    #                                                                     $     .data
    #                                                                     $     <alignment-directive>
    #                                                                     $ <name>:
    #                                                                     $     .long <init>
    cdef str name = emit_identifier(node.name)
    emit_global_directive_top_level(node.is_global, name)
    emit(".data", 1)
    emit_alignment_directive_top_level()
    emit(f"{name}:", 0)
    cdef initial_value = emit_int(node.initial_value)
    emit(f".long {initial_value}", 1)


cdef void emit_bss_static_variable_top_level(AsmStaticVariable node):
    # StaticVariable(name, global, init) initialized to zero -> $     <global-directive>
    #                                                           $     .bss
    #                                                           $     <alignment-directive>
    #                                                           $ <name>:
    #                                                           $     .zero 4
    cdef str name = emit_identifier(node.name)
    emit_global_directive_top_level(node.is_global, name)
    emit(".bss", 1)
    emit_alignment_directive_top_level()
    emit(f"{name}:", 0)
    emit(f".zero 4", 1)


cdef void emit_static_variable_top_level(AsmStaticVariable node):
    # StaticVariable(name, global, init) initialized to non-zero value -> $ <data-static-variable-directives>
    # StaticVariable(name, global, init) initialized to zero           -> $ <bss-static-variable-directives>
    if AsmStaticVariable.initial_value:
        emit_data_static_variable_top_level(node)
    else:
        emit_bss_static_variable_top_level(node)


cdef void emit_top_level(AsmTopLevel node):
    # Function(name, global, instructions) -> $ <function-top-level-directives>
    # StaticVariable(name, global, init)   -> $ <static-variable-top-level-directives>
    if isinstance(node, AsmFunction):
        emit_function_top_level(node)
    elif isinstance(node, AsmStaticVariable):
        emit_static_variable_top_level(node)
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef void emit_program(AsmProgram node):
    # Program(top_level*) -> $ [<top_level>]
    #                        $     .section .note.GNU-stack,"",@progbits
    cdef Py_ssize_t top_level
    for top_level in range(len(node.top_levels)):
        emit_top_level(node.top_levels[top_level])
    emit(".section .note.GNU-stack,\"\",@progbits", 1)

#
cdef list[str] code_emission_print(AsmProgram asm_ast): #
    global debug #
    debug = True #
    print_code.clear() #
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
