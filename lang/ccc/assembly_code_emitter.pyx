from ccc.abc_builtin_ast cimport TLong, TUInt, TULong, TDouble

from ccc.semantic_symbol_table cimport IntInit, LongInit, UIntInit, ULongInit, DoubleInit

from ccc.assembly_asm_ast cimport *
from ccc.assembly_backend_symbol_table cimport LongWord, QuadWord, BackendDouble

from ccc.util_ctypes cimport int32, double_to_binary
from ccc.util_fopen cimport file_open_write, write_line, file_close_write


cdef str emit_identifier(TIdentifier node):
    # identifier -> $ identifier
    return node.str_t


cdef str emit_int(TInt node):
    # int -> $ int
    return str(node.int_t)


cdef str emit_long(TLong node):
    # long -> $ long
    return str(node.long_t)


cdef str emit_uint(TUInt node):
    # uint -> $ uint
    return str(node.uint_t)


cdef str emit_ulong(TULong node):
    # ulong -> $ ulong
    return str(node.ulong_t)


cdef str emit_double(TDouble node):
    # double -> $ double
    return str(double_to_binary(node.double_t))


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
    # Reg(AX)    -> $ %rax
    # Reg(DX)    -> $ %rdx
    # Reg(CX)    -> $ %rcx
    # Reg(DI)    -> $ %rdi
    # Reg(SI)    -> $ %rsi
    # Reg(R8)    -> $ %r8
    # Reg(R9)    -> $ %r9
    # Reg(R10)   -> $ %r10
    # Reg(R11)   -> $ %r11
    # Reg(SP)    -> $ %rsp
    # Reg(XMM0)  -> $ %xmm0
    # Reg(XMM1)  -> $ %xmm1
    # Reg(XMM2)  -> $ %xmm2
    # Reg(XMM3)  -> $ %xmm3
    # Reg(XMM4)  -> $ %xmm4
    # Reg(XMM5)  -> $ %xmm5
    # Reg(XMM6)  -> $ %xmm6
    # Reg(XMM7)  -> $ %xmm7
    # Reg(XMM14) -> $ %xmm14
    # Reg(XMM15) -> $ %xmm15
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
    elif isinstance(node, AsmSp):
        return "rsp"
    elif isinstance(node, AsmXMM0):
        return "xmm0"
    elif isinstance(node, AsmXMM1):
        return "xmm1"
    elif isinstance(node, AsmXMM2):
        return "xmm2"
    elif isinstance(node, AsmXMM3):
        return "xmm3"
    elif isinstance(node, AsmXMM4):
        return "xmm4"
    elif isinstance(node, AsmXMM5):
        return "xmm5"
    elif isinstance(node, AsmXMM6):
        return "xmm6"
    elif isinstance(node, AsmXMM7):
        return "xmm7"
    elif isinstance(node, AsmXMM14):
        return "xmm14"
    elif isinstance(node, AsmXMM15):
        return "xmm15"
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
    # B  -> $ b
    # BE -> $ be
    # A  -> $ a
    # AE -> $ ae
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
    elif isinstance(node, AsmB):
        return "b"
    elif isinstance(node, AsmBE):
        return "be"
    elif isinstance(node, AsmA):
        return "a"
    elif isinstance(node, AsmAE):
        return "ae"
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef int32 emit_type_alignment_bytes(AssemblyType node):
    # LongWord -> $ 4
    # QuadWord -> $ 8
    # Double   -> $ 8
    if isinstance(node, LongWord):
        return 4
    elif isinstance(node, (QuadWord, BackendDouble)):
        return 8
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef str emit_type_instruction_suffix(AssemblyType node):
    # LongWord -> $ l
    # QuadWord -> $ q
    # Double   -> $ sd
    if isinstance(node, LongWord):
        return "l"
    elif isinstance(node, QuadWord):
        return "q"
    elif isinstance(node, BackendDouble):
        return "sd"
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
        operand = emit_identifier(node.value)
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
    # Add           -> $ add
    # Sub           -> $ sub
    # Mult<i>       -> $ imul
    # Mult<d>       -> $ mul
    # DivDouble     -> $ div
    # BitAnd        -> $ and
    # BitOr         -> $ or
    # BitXor        -> $ xor
    # BitShiftLeft  -> $ shl
    # BitShiftRight -> $ shr
    if isinstance(node, AsmAdd):
        return "add"
    elif isinstance(node, AsmSub):
        return "sub"
    elif isinstance(node, AsmMult):
        return "mul"
    elif isinstance(node, AsmDivDouble):
        return "div"
    elif isinstance(node, AsmBitAnd):
        return "and"
    elif isinstance(node, AsmBitOr):
        return "or"
    elif isinstance(node, AsmBitXor):
        return "xor"
    elif isinstance(node, AsmBitShiftLeft):
        return "shl"
    elif isinstance(node, AsmBitShiftRight):
        return "shr"
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef str emit_unary_op(AsmUnaryOp node):
    # Neg -> $ neg
    # Not -> $ not
    # Shr -> $ shr
    if isinstance(node, AsmNeg):
        return "neg"
    elif isinstance(node, AsmNot):
        return "not"
    elif isinstance(node, AsmShr):
        return "shr"
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
    cdef int32 byte = emit_type_alignment_bytes(node.assembly_type)
    cdef str t = emit_type_instruction_suffix(node.assembly_type)
    cdef str src = emit_operand(node.src, byte)
    cdef str dst = emit_operand(node.dst, byte)
    emit(f"mov{t} {src}, {dst}", 1)


cdef void emit_mov_sx_instructions(AsmMovSx node):
    cdef str src = emit_operand(node.src, 4)
    cdef str dst = emit_operand(node.dst, 8)
    emit(f"movslq {src}, {dst}", 1)


cdef void emit_cvttsd2si_instructions(AsmCvttsd2si node):
    cdef int32 byte = emit_type_alignment_bytes(node.assembly_type)
    cdef str t = emit_type_instruction_suffix(node.assembly_type)
    cdef str src = emit_operand(node.src, byte)
    cdef str dst = emit_operand(node.dst, byte)
    emit(f"cvttsd2si{t} {src}, {dst}", 1)


cdef void emit_cvtsi2sd_instructions(AsmCvtsi2sd node):
    cdef int32 byte = emit_type_alignment_bytes(node.assembly_type)
    cdef str t = emit_type_instruction_suffix(node.assembly_type)
    cdef str src = emit_operand(node.src, byte)
    cdef str dst = emit_operand(node.dst, byte)
    emit(f"cvtsi2sd{t} {src}, {dst}", 1)


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
    cdef int32 byte = emit_type_alignment_bytes(node.assembly_type)
    cdef str t = emit_type_instruction_suffix(node.assembly_type)
    cdef str src = emit_operand(node.src, byte)
    cdef str dst = emit_operand(node.dst, byte)
    if isinstance(node.assembly_type, BackendDouble):
        emit(f"comi{t} {src}, {dst}", 1)
    else:
        emit(f"cmp{t} {src}, {dst}", 1)

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
    cdef int32 byte = emit_type_alignment_bytes(node.assembly_type)
    cdef str t = emit_type_instruction_suffix(node.assembly_type)
    cdef str unary_op = emit_unary_op(node.unary_op)
    cdef str dst = emit_operand(node.dst, byte)
    emit(f"{unary_op}{t} {dst}", 1)


cdef void emit_binary_instructions(AsmBinary node):
    cdef int32 byte = emit_type_alignment_bytes(node.assembly_type)
    cdef str t
    if isinstance(node.binary_op, AsmBitXor) and \
       isinstance(node.assembly_type, BackendDouble):
        t = "pd"
    else:
        t = emit_type_instruction_suffix(node.assembly_type)
    cdef str binary_op = emit_binary_op(node.binary_op)
    if isinstance(node.binary_op, AsmMult) and \
       not isinstance(node.assembly_type, BackendDouble):
        binary_op = f"i{binary_op}"
    cdef str src = emit_operand(node.src, byte)
    cdef str dst = emit_operand(node.dst, byte)
    emit(f"{binary_op}{t} {src}, {dst}", 1)


cdef void emit_idiv_instructions(AsmIdiv node):
    cdef int32 byte = emit_type_alignment_bytes(node.assembly_type)
    cdef str t = emit_type_instruction_suffix(node.assembly_type)
    cdef str src = emit_operand(node.src, byte)
    emit(f"idiv{t} {src}", 1)


cdef void emit_div_instructions(AsmDiv node):
    cdef int32 byte = emit_type_alignment_bytes(node.assembly_type)
    cdef str t = emit_type_instruction_suffix(node.assembly_type)
    cdef str src = emit_operand(node.src, byte)
    emit(f"div{t} {src}", 1)


cdef void emit_cdq_instructions(AsmCdq node):
    if isinstance(node.assembly_type, LongWord):
        emit("cdq", 1)
    elif isinstance(node.assembly_type, QuadWord):
        emit("cqo", 1)
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef void emit_instructions(AsmInstruction node):
    # Ret                                  -> $ movq %rbp, %rsp
    #                                         $ popq %rbp
    #                                         $ ret
    # Mov(t, src, dst)                     -> $ mov<t> <src>, <dst>
    # MovSx(src, dst)                      -> $ movslq <src>, <dst>
    # Cvttsd2si(t, src, dst)               -> $ cvttsd2si<t> <src>, <dst>
    # Cvtsi2sd(t, src, dst)                -> $ cvtsi2sd<t> <src>, <dst>
    # Push(operand)                        -> $ pushq <operand>
    # Call(label)                          -> $ call <label>@PLT
    # Label(label)                         -> $ .L<label>:
    # Cmp(t, operand, operand)<i>          -> $ cmp<t> <operand>, <operand>
    # Cmp(t, operand, operand)<d>          -> $ comi<t> <operand>, <operand>
    # Jmp(label)                           -> $ jmp .L<label>
    # JmpCC(cond_code, label)              -> $ j<cond_code> .L<label>
    # SetCC(cond_code, operand)            -> $ set<cond_code> <operand>
    # Unary(unary_operator, t, operand)    -> $ <unary_operator><t> <operand>
    # Binary(binary_operator, t, src, dst) -> $ <binary_operator><t> <src>, <dst>
    # Idiv(t, operand)                     -> $ idiv<t> <operand>
    # Div(t, operand)                      -> $ div<t> <operand>
    # Cdq<l>                               -> $ cdq
    # Cdq<q>                               -> $ cqo
    if isinstance(node, AsmRet):
        emit_ret_instructions(node)
    elif isinstance(node, AsmMov):
        emit_mov_instructions(node)
    elif isinstance(node, AsmMovSx):
        emit_mov_sx_instructions(node)
    elif isinstance(node, AsmCvttsd2si):
        emit_cvttsd2si_instructions(node)
    elif isinstance(node, AsmCvtsi2sd):
        emit_cvtsi2sd_instructions(node)
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
    elif isinstance(node, AsmDiv):
        emit_div_instructions(node)
    elif isinstance(node, AsmCdq):
        emit_cdq_instructions(node)
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef void emit_list_instructions(list[AsmInstruction] list_node):
    cdef Py_ssize_t instruction
    for instruction in range(len(list_node)):
        emit_instructions(list_node[instruction])


cdef void emit_alignment_directive_top_level(TInt alignment):
    # $ .align <alignment>
    cdef str align = emit_int(alignment)
    emit(f".align {align}", 1)


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


cdef void emit_data_static_variable_top_level(AsmStaticVariable node, str static_init):
    # StaticVariable(name, global, init) initialized to non-zero value -> $     <global-directive>
    #                                                                     $     .data
    #                                                                     $     <alignment-directive>
    #                                                                     $ <name>:
    #                                                       if init<i>(i) $     .long <i>
    #                                                     elif init<i>(i) $     .quad <i>
    #                                                     elif init<d>(d) $     .quad <d>
    cdef str name = emit_identifier(node.name)
    emit_global_directive_top_level(node.is_global, name)
    emit(".data", 1)
    emit_alignment_directive_top_level(node.alignment)
    emit(f"{name}:", 0)
    emit(static_init, 1)


cdef void emit_bss_static_variable_top_level(AsmStaticVariable node, str static_init):
    # StaticVariable(name, global, init) initialized to zero -> $     <global-directive>
    #                                                           $     .bss
    #                                                           $     <alignment-directive>
    #                                                           $ <name>:
    #                                            if int-init(0) $     .zero 4
    #                                         elif long-init(0) $     .zero 8
    cdef str name = emit_identifier(node.name)
    emit_global_directive_top_level(node.is_global, name)
    emit(".bss", 1)
    emit_alignment_directive_top_level(node.alignment)
    emit(f"{name}:", 0)
    emit(static_init, 1)


cdef void emit_static_variable_top_level(AsmStaticVariable node):
    # StaticVariable(name, global, align, init)<i> initialized to non-zero value -> $ <data-static-variable-directives>
    # StaticVariable(name, global, align, init)<d>                               -> $ <data-static-variable-directives>
    # StaticVariable(name, global, align, init)<i> initialized to zero           -> $ <bss-static-variable-directives>
    cdef str static_init
    if isinstance(node.initial_value, IntInit):
        if node.initial_value.value.int_t:
            static_init = emit_int(node.initial_value.value)
            static_init = f".long {static_init}"
            emit_data_static_variable_top_level(node, static_init)
        else:
            static_init = ".zero 4"
            emit_bss_static_variable_top_level(node, static_init)
    elif isinstance(node.initial_value, LongInit):
        if node.initial_value.value.long_t:
            static_init = emit_long(node.initial_value.value)
            static_init = f".quad {static_init}"
            emit_data_static_variable_top_level(node, static_init)
        else:
            static_init = ".zero 8"
            emit_bss_static_variable_top_level(node, static_init)
    elif isinstance(node.initial_value, DoubleInit):
        static_init = emit_double(node.initial_value.value)
        static_init = f".quad {static_init}"
        emit_data_static_variable_top_level(node, static_init)
    elif isinstance(node.initial_value, UIntInit):
        if node.initial_value.value.uint_t:
            static_init = emit_uint(node.initial_value.value)
            static_init = f".long {static_init}"
            emit_data_static_variable_top_level(node, static_init)
        else:
            static_init = ".zero 4"
            emit_bss_static_variable_top_level(node, static_init)
    elif isinstance(node.initial_value, ULongInit):
        if node.initial_value.value.ulong_t:
            static_init = emit_ulong(node.initial_value.value)
            static_init = f".quad {static_init}"
            emit_data_static_variable_top_level(node, static_init)
        else:
            static_init = ".zero 8"
            emit_bss_static_variable_top_level(node, static_init)
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef void emit_double_static_constant_top_level(AsmStaticConstant node):
    # StaticConstant(name, align, init) -> $     .section .rodata
    #                                      $     <alignment-directive>
    #                                      $ .L<name>:
    #                                      $     .quad <d>
    cdef str name = emit_identifier(node.name)
    cdef str static_init = emit_double(node.initial_value.value)
    emit(".section .rodata", 1)
    emit_alignment_directive_top_level(node.alignment)
    emit(f".L{name}:", 0)
    emit(f".quad {static_init}", 1)


cdef void emit_static_constant_top_level(AsmStaticConstant node):
    # StaticConstant(name, align, init)<d> -> $ <double-static-constant-directives>
    if isinstance(node.initial_value, DoubleInit):
        emit_double_static_constant_top_level(node)
    else:

        raise RuntimeError(
            "An error occurred in code emission, not all nodes were visited")


cdef void emit_top_level(AsmTopLevel node):
    # Function(name, global, instructions)      -> $ <function-top-level-directives>
    # StaticVariable(name, global, align, init) -> $ <static-variable-top-level-directives>
    # StaticConstant(name, align, init)         -> $ <static-constant-top-level-directives>
    if isinstance(node, AsmFunction):
        emit_function_top_level(node)
    elif isinstance(node, AsmStaticVariable):
        emit_static_variable_top_level(node)
    elif isinstance(node, AsmStaticConstant):
        emit_static_constant_top_level(node)
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
