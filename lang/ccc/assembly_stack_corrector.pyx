from ccc.abc_builtin_ast cimport copy_identifier

from ccc.assembly_asm_ast cimport TIdentifier, TInt, AsmProgram
from ccc.assembly_asm_ast cimport AsmTopLevel, AsmFunction, AsmStaticVariable, AsmStaticConstant
from ccc.assembly_asm_ast cimport AsmInstruction, AsmImm, AsmMov, AsmMovSx, AsmMovZeroExtend, AsmCvttsd2si, AsmCvtsi2sd
from ccc.assembly_asm_ast cimport AsmPush, AsmCmp, AsmSetCC, AsmUnary, AsmBinary
from ccc.assembly_asm_ast cimport AsmBinaryOp, AsmAdd, AsmSub, AsmIdiv, AsmDiv, AsmMult
from ccc.assembly_asm_ast cimport AsmOperand, AsmPseudo, AsmStack, AsmData
from ccc.assembly_asm_ast cimport AsmBitAnd, AsmBitOr, AsmBitXor, AsmBitShiftLeft, AsmBitShiftRight
from ccc.assembly_register cimport REGISTER_KIND, generate_register
from ccc.assembly_backend_symbol_table cimport backend_symbol_table, AssemblyType, LongWord, QuadWord, BackendDouble

from ccc.util_ctypes cimport int32


cdef int32 OFFSET_32_BITS = -4
cdef int32 OFFSET_64_BITS = -8
cdef int32 counter = -1
cdef dict[str, int32] pseudo_map = {}


cdef AsmData replace_pseudo_register_data(AsmPseudo node):
    cdef TIdentifier name = copy_identifier(node.name)
    return AsmData(name)


cdef AsmStack replace_pseudo_register_stack(AsmPseudo node):
    cdef TInt value = TInt(pseudo_map[node.name.str_t])
    return AsmStack(value)


cdef void allocate_offset_pseudo_register(AssemblyType assembly_type):
    global counter

    if isinstance(assembly_type, LongWord):
        counter += OFFSET_32_BITS
    elif isinstance(assembly_type, (QuadWord, BackendDouble)):
        counter += OFFSET_64_BITS


cdef void align_offset_pseudo_register(AssemblyType assembly_type):
    global counter

    if isinstance(assembly_type, LongWord):
        counter += OFFSET_32_BITS


cdef AsmOperand replace_operand_pseudo_register(AsmPseudo node):
    global pseudo_map

    if node.name.str_t not in pseudo_map:
        if backend_symbol_table[node.name.str_t].is_static:
            return replace_pseudo_register_data(node)
        else:
            allocate_offset_pseudo_register(backend_symbol_table[node.name.str_t].assembly_type)
            pseudo_map[node.name.str_t] = counter
            align_offset_pseudo_register(backend_symbol_table[node.name.str_t].assembly_type)
    return replace_pseudo_register_stack(node)


cdef void replace_mov_pseudo_registers(AsmMov node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)
    if isinstance(node.dst, AsmPseudo):
        node.dst = replace_operand_pseudo_register(node.dst)


cdef void replace_mov_sx_pseudo_registers(AsmMovSx node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)
    if isinstance(node.dst, AsmPseudo):
        node.dst = replace_operand_pseudo_register(node.dst)


cdef void replace_mov_zero_extend_pseudo_registers(AsmMovZeroExtend node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)
    if isinstance(node.dst, AsmPseudo):
        node.dst = replace_operand_pseudo_register(node.dst)


cdef void replace_cvttsd2si_pseudo_registers(AsmCvttsd2si node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)
    if isinstance(node.dst, AsmPseudo):
        node.dst = replace_operand_pseudo_register(node.dst)


cdef void replace_cvtsi2sd_pseudo_registers(AsmCvtsi2sd node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)
    if isinstance(node.dst, AsmPseudo):
        node.dst = replace_operand_pseudo_register(node.dst)


cdef void replace_push_pseudo_registers(AsmPush node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)


cdef void replace_cmp_pseudo_registers(AsmCmp node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)
    if isinstance(node.dst, AsmPseudo):
        node.dst = replace_operand_pseudo_register(node.dst)


cdef void replace_set_cc_pseudo_registers(AsmSetCC node):
    if isinstance(node.dst, AsmPseudo):
        node.dst = replace_operand_pseudo_register(node.dst)


cdef void replace_unary_pseudo_registers(AsmUnary node):
    if isinstance(node.dst, AsmPseudo):
        node.dst = replace_operand_pseudo_register(node.dst)


cdef void replace_binary_pseudo_registers(AsmBinary node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)
    if isinstance(node.dst, AsmPseudo):
        node.dst = replace_operand_pseudo_register(node.dst)


cdef void replace_idiv_pseudo_registers(AsmIdiv node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)


cdef void replace_div_pseudo_registers(AsmDiv node):
    if isinstance(node.src, AsmPseudo):
        node.src = replace_operand_pseudo_register(node.src)


cdef void replace_pseudo_registers(AsmInstruction node):
    if isinstance(node, AsmMov):
        replace_mov_pseudo_registers(node)
    elif isinstance(node, AsmMovSx):
        replace_mov_sx_pseudo_registers(node)
    elif isinstance(node, AsmMovZeroExtend):
        replace_mov_zero_extend_pseudo_registers(node)
    elif isinstance(node, AsmCvttsd2si):
        replace_cvttsd2si_pseudo_registers(node)
    elif isinstance(node, AsmCvtsi2sd):
        replace_cvtsi2sd_pseudo_registers(node)
    elif isinstance(node, AsmPush):
        replace_push_pseudo_registers(node)
    elif isinstance(node, AsmCmp):
        replace_cmp_pseudo_registers(node)
    elif isinstance(node, AsmSetCC):
        replace_set_cc_pseudo_registers(node)
    elif isinstance(node, AsmUnary):
        replace_unary_pseudo_registers(node)
    elif isinstance(node, AsmBinary):
        replace_binary_pseudo_registers(node)
    elif isinstance(node, AsmIdiv):
        replace_idiv_pseudo_registers(node)
    elif isinstance(node, AsmDiv):
        replace_div_pseudo_registers(node)


cdef AsmBinary allocate_stack_bytes(int32 byte):
    cdef AsmBinaryOp binary_op = AsmSub()
    cdef AssemblyType assembly_type = QuadWord()
    cdef bint is_long = False
    cdef AsmOperand src = AsmImm(TIdentifier(str(byte)), is_long)
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    return AsmBinary(binary_op, assembly_type, src, dst)


cdef AsmBinary deallocate_stack_bytes(int32 byte):
    cdef AsmBinaryOp binary_op = AsmAdd()
    cdef AssemblyType assembly_type = QuadWord()
    cdef bint is_long = False
    cdef AsmOperand src = AsmImm(TIdentifier(str(byte)), is_long)
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    return AsmBinary(binary_op, assembly_type, src, dst)


cdef list[AsmInstruction] fix_instructions = []


cdef void set_alloc_stack():
    cdef int32 byte = -1 * counter

    if byte % 8 != 0:

        raise RuntimeError(
            f"An error occurred in function stack allocation, stack alignment {byte} is not a multiple of 8")

    fix_instructions[0].src.value.str_t = str(byte)


cdef void swap_fix_instruction_back():
    fix_instructions[-1], fix_instructions[-2] = fix_instructions[-2], fix_instructions[-1]


cdef void correct_any_from_addr_to_addr_instruction():
    # mov | cmp | add | sub | and | or | xor (addr, addr)
    # $ mov addr1, addr2 ->
    #     $ mov addr1, reg
    #     $ mov reg  , addr2
    cdef AsmOperand src_src = fix_instructions[-1].src
    fix_instructions[-1].src = generate_register(REGISTER_KIND.get('R10'))
    fix_instructions.append(AsmMov(fix_instructions[-1].assembly_type, src_src, fix_instructions[-1].src))
    swap_fix_instruction_back()


cdef void correct_double_mov_from_addr_to_addr_instructions():
    # mov<q> (_, addr)
    # $ mov<q> addr1, addr2 ->
    #     $ mov    addr1, reg
    #     $ mov<q> reg  , addr2
    cdef AsmOperand src_src = fix_instructions[-1].src
    fix_instructions[-1].src = generate_register(REGISTER_KIND.get('Xmm14'))
    fix_instructions.append(AsmMov(fix_instructions[-1].assembly_type, src_src, fix_instructions[-1].src))
    swap_fix_instruction_back()


cdef void correct_mov_sx_from_imm_to_any_instructions():
    # movsx (imm, _)
    # $ movsx imm, _ ->
    #     $ mov   imm, reg
    #     $ movsx reg, _
    cdef AsmOperand src_src = fix_instructions[-1].src
    fix_instructions[-1].src = generate_register(REGISTER_KIND.get('R10'))
    fix_instructions.append(AsmMov(LongWord(), src_src, fix_instructions[-1].src))
    swap_fix_instruction_back()


cdef void correct_mov_sx_zero_extend_from_any_to_addr_instructions():
    # movsx | mov0x (_, addr)
    # $ movsx _, addr ->
    #     $ movsx _  , reg
    #     $ mov   reg, addr
    cdef AsmOperand src_dst = fix_instructions[-1].dst
    fix_instructions[-1].dst = generate_register(REGISTER_KIND.get('R11'))
    fix_instructions.append(AsmMov(QuadWord(), fix_instructions[-1].dst, src_dst))


cdef void correct_mov_zero_extend_from_any_to_any_instructions():
    fix_instructions[-1] = AsmMov(LongWord(), fix_instructions[-1].src, fix_instructions[-1].dst)


cdef void correct_cvttsd2si_from_any_to_addr_instructions():
    # cvttsd2si (_, addr)
    # $ cvttsd2si _, addr ->
    #     $ cvttsd2si _  , reg
    #     $ mov       reg, addr
    cdef AsmOperand src_dst = fix_instructions[-1].dst
    fix_instructions[-1].dst = generate_register(REGISTER_KIND.get('R11'))
    fix_instructions.append(AsmMov(fix_instructions[-1].assembly_type, fix_instructions[-1].dst, src_dst))


cdef void correct_cvtsi2sd_from_imm_to_any_instructions():
    # cvtsi2sd (imm, _)
    # $ cvtsi2sd imm, _ ->
    #     $ mov      imm, reg
    #     $ cvtsi2sd reg, _
    cdef AsmOperand src_src = fix_instructions[-1].src
    fix_instructions[-1].src = generate_register(REGISTER_KIND.get('R10'))
    fix_instructions.append(AsmMov(fix_instructions[-1].assembly_type, src_src, fix_instructions[-1].src))
    swap_fix_instruction_back()


cdef void correct_cvtsi2sd_from_any_to_addr_instructions():
    # cvtsi2sd | add<q> | sub<q> | mul<q> | div<q> | xor<q> (_, addr)
    # $ cvtsi2sd _, addr ->
    #     $ cvtsi2sd _  , reg
    #     $ mov      reg, addr
    cdef AsmOperand src_dst = fix_instructions[-1].dst
    fix_instructions[-1].dst = generate_register(REGISTER_KIND.get('Xmm15'))
    fix_instructions.append(AsmMov(BackendDouble(), fix_instructions[-1].dst, src_dst))


cdef void correct_cmp_from_any_to_imm_instructions():
    # cmp (_, imm)
    # $ cmp reg1, imm ->
    #     $ mov imm , reg2
    #     $ cmp reg1, reg2
    cdef AsmOperand src_dst = fix_instructions[-1].dst
    fix_instructions[-1].dst = generate_register(REGISTER_KIND.get('R11'))
    fix_instructions.append(AsmMov(fix_instructions[-1].assembly_type, src_dst, fix_instructions[-1].dst))
    swap_fix_instruction_back()


cdef correct_double_cmp_from_any_to_addr_instructions():
    # cmp<d> (_, addr)
    # $ cmp<d> _, addr ->
    #     $ mov    addr, reg
    #     $ cmp<d> _   , reg
    cdef AsmOperand dst_dst = fix_instructions[-1].dst
    fix_instructions[-1].dst = generate_register(REGISTER_KIND.get('Xmm15'))
    fix_instructions.append(AsmMov(BackendDouble(), dst_dst, fix_instructions[-1].dst))
    swap_fix_instruction_back()


cdef void correct_shl_shr_from_addr_to_addr():
    # shl | shr (addr, addr)
    # $ shl addr1, addr2 ->
    #     $ mov addr1, reg
    #     $ shl reg, addr2
    cdef AsmOperand src_src = fix_instructions[-1].src
    fix_instructions[-1].src = generate_register(REGISTER_KIND.get('Cx'))
    fix_instructions.append(AsmMov(fix_instructions[-1].assembly_type, src_src, fix_instructions[-1].src))
    swap_fix_instruction_back()


cdef void correct_mul_from_any_to_addr():
    # imul (_, addr)
    # $ imul imm, addr ->
    #     $ mov  addr, reg
    #     $ imul imm , reg
    #     $ mov  reg , addr
    cdef AsmOperand src_src = fix_instructions[-1].dst
    cdef AsmOperand dst_dst = fix_instructions[-1].dst
    fix_instructions[-1].dst = generate_register(REGISTER_KIND.get('R11'))
    fix_instructions.append(AsmMov(fix_instructions[-1].assembly_type, src_src, fix_instructions[-1].dst))
    swap_fix_instruction_back()
    fix_instructions.append(AsmMov(fix_instructions[-1].assembly_type, fix_instructions[-1].dst, dst_dst))


cdef void correct_binary_from_any_to_addr_instructions():
    # add<q> | sub<q> | mul<q> | div<q> | xor<q> (_, addr)
    # $ add<q> _, addr ->
    #     $ add<q> _  , reg
    #     $ mov    reg, addr
    cdef AsmOperand src_dst = fix_instructions[-1].dst
    fix_instructions[-1].dst = generate_register(REGISTER_KIND.get('Xmm15'))
    fix_instructions.append(AsmMov(BackendDouble(), src_dst, fix_instructions[-1].dst))
    swap_fix_instruction_back()
    fix_instructions.append(AsmMov(BackendDouble(), fix_instructions[-1].dst, src_dst))


cdef void correct_div_from_imm():
    # idiv | div (imm)
    # $ idiv imm ->
    #     $ mov  imm, reg
    #     $ idiv reg
    cdef AsmOperand src_src = fix_instructions[-1].src
    fix_instructions[-1].src = generate_register(REGISTER_KIND.get('R10'))
    fix_instructions.append(AsmMov(fix_instructions[-1].assembly_type, src_src, fix_instructions[-1].src))
    swap_fix_instruction_back()


cdef void correct_any_from_quad_word_imm_to_any():
    # mov | cmp | push | add | sub | mul (q imm, _)
    # $ mov imm<q>, _ ->
    #     $ mov imm<q>, reg
    #     $ mov reg   , _
    cdef AsmOperand src_src = fix_instructions[-1].src
    fix_instructions[-1].src = generate_register(REGISTER_KIND.get('R10'))
    fix_instructions.append(AsmMov(QuadWord(), src_src, fix_instructions[-1].src))
    swap_fix_instruction_back()


cdef bint is_from_long_imm_instruction():
    return isinstance(fix_instructions[-1].src, AsmImm) and \
            fix_instructions[-1].src.is_long


cdef bint is_from_imm_instruction():
    return isinstance(fix_instructions[-1].src, AsmImm)


cdef bint is_to_imm_instruction():
    return isinstance(fix_instructions[-1].dst, AsmImm)


cdef bint is_from_addr_instruction():
    return isinstance(fix_instructions[-1].src, (AsmStack, AsmData))


cdef bint is_to_addr_instruction():
    return isinstance(fix_instructions[-1].dst, (AsmStack, AsmData))


cdef bint is_from_addr_to_addr_instruction():
    return is_from_addr_instruction() and \
           is_to_addr_instruction()


cdef void correct_function_top_level(AsmFunction node):
    global fix_instructions
    fix_instructions = [allocate_stack_bytes(0)]

    cdef Py_ssize_t i
    for i in range(len(node.instructions)):
        fix_instructions.append(node.instructions[i])
        node.instructions[i] = None

        replace_pseudo_registers(fix_instructions[-1])

        if isinstance(fix_instructions[-1], AsmMov):
            if isinstance(fix_instructions[-1].assembly_type, BackendDouble):
                if is_from_addr_to_addr_instruction():
                    correct_double_mov_from_addr_to_addr_instructions()
            else:
                if is_from_long_imm_instruction():
                    correct_any_from_quad_word_imm_to_any()

                if is_from_addr_to_addr_instruction():
                    correct_any_from_addr_to_addr_instruction()

        elif isinstance(fix_instructions[-1], AsmMovSx):
            if is_from_imm_instruction():
                correct_mov_sx_from_imm_to_any_instructions()

            if is_to_addr_instruction():
                correct_mov_sx_zero_extend_from_any_to_addr_instructions()

        elif isinstance(fix_instructions[-1], AsmMovZeroExtend):
            correct_mov_zero_extend_from_any_to_any_instructions()

            if is_to_addr_instruction():
                correct_mov_sx_zero_extend_from_any_to_addr_instructions()

        elif isinstance(fix_instructions[-1], AsmCvttsd2si):
            if is_to_addr_instruction():
                correct_cvttsd2si_from_any_to_addr_instructions()

        elif isinstance(fix_instructions[-1], AsmCvtsi2sd):
            if is_from_imm_instruction():
                correct_cvtsi2sd_from_imm_to_any_instructions()

            if is_to_addr_instruction():
                correct_cvtsi2sd_from_any_to_addr_instructions()

        elif isinstance(fix_instructions[-1], AsmCmp):
            if isinstance(fix_instructions[-1].assembly_type, BackendDouble):
                if is_to_addr_instruction():
                    correct_double_cmp_from_any_to_addr_instructions()

            else:
                if is_from_long_imm_instruction():
                    correct_any_from_quad_word_imm_to_any()

                if is_from_addr_to_addr_instruction():
                    correct_any_from_addr_to_addr_instruction()

                elif is_to_imm_instruction():
                    correct_cmp_from_any_to_imm_instructions()

        elif isinstance(fix_instructions[-1], AsmPush):
            if is_from_long_imm_instruction():
                correct_any_from_quad_word_imm_to_any()

        elif isinstance(fix_instructions[-1], AsmBinary):
            if isinstance(fix_instructions[-1].assembly_type, BackendDouble):
                if is_to_addr_instruction():
                    correct_binary_from_any_to_addr_instructions()

            else:
                if isinstance(fix_instructions[-1].binary_op,
                              (AsmAdd, AsmSub, AsmBitAnd, AsmBitOr, AsmBitXor)):
                    if is_from_long_imm_instruction():
                        correct_any_from_quad_word_imm_to_any()

                    if is_from_addr_to_addr_instruction():
                        correct_any_from_addr_to_addr_instruction()

                elif isinstance(fix_instructions[-1].binary_op,
                                (AsmBitShiftLeft, AsmBitShiftRight)):
                    if is_from_long_imm_instruction():
                        correct_any_from_quad_word_imm_to_any()

                    if is_from_addr_to_addr_instruction():
                        correct_shl_shr_from_addr_to_addr()

                elif isinstance(fix_instructions[-1].binary_op, AsmMult):
                    if is_from_long_imm_instruction():
                        correct_any_from_quad_word_imm_to_any()

                    if is_to_addr_instruction():
                        correct_mul_from_any_to_addr()

        elif isinstance(fix_instructions[-1], (AsmIdiv, AsmDiv)):
            if is_from_imm_instruction():
                correct_div_from_imm()

    set_alloc_stack()
    node.instructions.clear()
    node.instructions = fix_instructions


cdef void correct_variable_stack_top_level(AsmStaticVariable node):
    pass


cdef void correct_top_level(AsmTopLevel node):
    if isinstance(node, AsmFunction):
        correct_function_top_level(node)
    elif isinstance(node, AsmStaticVariable):
        correct_variable_stack_top_level(node)
    elif isinstance(node, AsmStaticConstant):
        pass
    else:

        raise RuntimeError(
            "An error occurred in stack management, not all nodes were visited")


cdef void init_correct_instructions():
    global counter
    counter = 0
    pseudo_map.clear()


cdef void correct_instructions(AsmProgram node):
    cdef Py_ssize_t top_level
    for top_level in range(len(node.top_levels)):
        init_correct_instructions()
        correct_top_level(node.top_levels[top_level])


cdef void correct_stack(AsmProgram asm_ast):

    correct_instructions(asm_ast)
