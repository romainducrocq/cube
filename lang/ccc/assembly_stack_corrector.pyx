from ccc.abc_builtin_ast cimport copy_identifier

from ccc.assembly_asm_ast cimport TIdentifier, TInt, AsmProgram
from ccc.assembly_asm_ast cimport AsmTopLevel, AsmFunction, AsmStaticVariable
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
    cdef AsmOperand src = AsmImm(TIdentifier(str(byte)), False)
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    return AsmBinary(binary_op, assembly_type, src, dst)


cdef AsmBinary deallocate_stack_bytes(int32 byte):
    cdef AsmBinaryOp binary_op = AsmAdd()
    cdef AssemblyType assembly_type = QuadWord()
    cdef AsmOperand src = AsmImm(TIdentifier(str(byte)), False)
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    return AsmBinary(binary_op, assembly_type, src, dst)


cdef list[AsmInstruction] fix_instructions = []


cdef void fix_allocate_stack_bytes():
    cdef int32 byte = -1 * counter

    if byte % 8 != 0:

        raise RuntimeError(
            f"An error occurred in function stack allocation, stack alignment {byte} is not a multiple of 8")

    fix_instructions[0].src.value.str_t = str(byte)


cdef void swap_fix_instructions_back():
    fix_instructions[-1], fix_instructions[-2] = fix_instructions[-2], fix_instructions[-1]


cdef void fix_double_mov_from_addr_to_addr_instruction(AsmMov node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Xmm14'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_mov_from_quad_word_imm_to_any_instruction(AsmMov node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = QuadWord()
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_mov_from_addr_to_addr_instruction(AsmMov node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_mov_instruction(AsmMov node):
    if isinstance(node.assembly_type, BackendDouble):
        if isinstance(node.src, (AsmStack, AsmData)) and \
           isinstance(node.dst, (AsmStack, AsmData)):
            fix_double_mov_from_addr_to_addr_instruction(node)

    else:
        if isinstance(node.src, AsmImm) and \
           node.src.is_quad:
            fix_mov_from_quad_word_imm_to_any_instruction(node)

        if isinstance(node.src, (AsmStack, AsmData)) and \
           isinstance(node.dst, (AsmStack, AsmData)):
            fix_mov_from_addr_to_addr_instruction(node)


cdef void fix_mov_sx_from_imm_to_any_instruction(AsmMovSx node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = LongWord()
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_mov_sx_from_any_to_addr_instruction(AsmMovSx node):
    cdef AsmOperand src = generate_register(REGISTER_KIND.get('R11'))
    cdef AsmOperand dst = node.dst
    cdef AssemblyType assembly_type = QuadWord()
    node.dst = src
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))


cdef void fix_mov_sx_instruction(AsmMovSx node):
    if isinstance(node.src, AsmImm):
        fix_mov_sx_from_imm_to_any_instruction(node)
        
    if isinstance(node.dst, (AsmStack, AsmData)):
        fix_mov_sx_from_any_to_addr_instruction(node)


cdef void fix_mov_zero_extend_from_any_to_any_instruction(AsmMovZeroExtend node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = node.dst
    cdef AssemblyType assembly_type = LongWord()
    fix_instructions[-1] = AsmMov(assembly_type, src, dst)


cdef void fix_mov_zero_extend_from_any_to_addr_instruction(AsmMov node):
    cdef AsmOperand src = generate_register(REGISTER_KIND.get('R11'))
    cdef AsmOperand dst = node.dst
    cdef AssemblyType assembly_type = QuadWord()
    node.dst = src
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))


cdef void fix_mov_zero_extend_instruction(AsmMovZeroExtend node):
    fix_mov_zero_extend_from_any_to_any_instruction(node)
    cdef AsmMov node_2 = fix_instructions[-1]

    if isinstance(node_2.dst, (AsmStack, AsmData)):
        fix_mov_zero_extend_from_any_to_addr_instruction(node_2)


cdef void fix_cvttsd2si_from_any_to_addr_instruction(AsmCvttsd2si node):
    cdef AsmOperand src = generate_register(REGISTER_KIND.get('R11'))
    cdef AsmOperand dst = node.dst
    cdef AssemblyType assembly_type = node.assembly_type
    node.dst = src
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))


cdef void fix_cvttsd2si_instruction(AsmCvttsd2si node):
    if isinstance(node.dst, (AsmStack, AsmData)):
        fix_cvttsd2si_from_any_to_addr_instruction(node)


cdef void fix_cvtsi2sd_from_imm_to_any_instruction(AsmCvtsi2sd node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_cvtsi2sd_from_any_to_addr_instruction(AsmCvtsi2sd node):
    cdef AsmOperand src = generate_register(REGISTER_KIND.get('Xmm15'))
    cdef AsmOperand dst = node.dst
    cdef AssemblyType assembly_type = BackendDouble()
    node.dst = src
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))


cdef void fix_cvtsi2sd_instruction(AsmCvtsi2sd node):
    if isinstance(node.src, AsmImm):
        fix_cvtsi2sd_from_imm_to_any_instruction(node)
        
    if isinstance(node.dst, (AsmStack, AsmData)):
        fix_cvtsi2sd_from_any_to_addr_instruction(node)


cdef fix_double_cmp_from_any_to_addr_instruction(AsmCmp node):
    cdef AsmOperand src = node.dst
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Xmm15'))
    cdef AssemblyType assembly_type = BackendDouble()
    node.dst = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_cmp_from_quad_word_imm_to_any_instruction(AsmCmp node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = QuadWord()
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_cmp_from_addr_to_addr_instruction(AsmCmp node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_cmp_from_any_to_imm_instruction(AsmCmp node):
    cdef AsmOperand src = node.dst
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R11'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.dst = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_cmp_instruction(AsmCmp node):
    if isinstance(node.assembly_type, BackendDouble):
        if isinstance(node.dst, (AsmStack, AsmData)):
            fix_double_cmp_from_any_to_addr_instruction(node)

    else:
        if isinstance(node.src, AsmImm) and \
           node.src.is_quad:
            fix_cmp_from_quad_word_imm_to_any_instruction(node)
            
        if isinstance(node.src, (AsmStack, AsmData)) and \
           isinstance(node.dst, (AsmStack, AsmData)):
            fix_cmp_from_addr_to_addr_instruction(node)

        elif isinstance(node.dst, AsmImm):
            fix_cmp_from_any_to_imm_instruction(node)


cdef void fix_push_from_quad_word_imm_to_any_instruction(AsmPush node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = QuadWord()
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_push_instruction(AsmPush node):
    if isinstance(node.src, AsmImm) and \
       node.src.is_quad:
        fix_push_from_quad_word_imm_to_any_instruction(node)


cdef void fix_double_binary_from_any_to_addr_instruction(AsmBinary node):
    cdef AsmOperand src = node.dst
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Xmm15'))
    cdef AssemblyType assembly_type = BackendDouble()
    node.dst = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()
    fix_instructions.append(AsmMov(assembly_type, dst, src))


cdef void fix_binary_from_quad_word_imm_to_any_instruction(AsmBinary node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = QuadWord()
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_binary_any_from_addr_to_addr_instruction(AsmBinary node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_binary_shx_from_addr_to_addr_instruction(AsmBinary node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Cx'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_binary_imul_from_any_to_addr_instruction(AsmBinary node):
    cdef AsmOperand src = node.dst
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R11'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.dst = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()
    fix_instructions.append(AsmMov(assembly_type, dst, src))


cdef void fix_binary_instruction(AsmBinary node):
    if isinstance(node.assembly_type, BackendDouble):
        if isinstance(node.dst, (AsmStack, AsmData)):
            fix_double_binary_from_any_to_addr_instruction(node)

    else:
        if isinstance(node.binary_op,
                      (AsmAdd, AsmSub, AsmBitAnd, AsmBitOr, AsmBitXor)):
            if isinstance(node.src, AsmImm) and \
               node.src.is_quad:
                fix_binary_from_quad_word_imm_to_any_instruction(node)
                
            if isinstance(node.src, (AsmStack, AsmData)) and \
               isinstance(node.dst, (AsmStack, AsmData)):
                fix_binary_any_from_addr_to_addr_instruction(node)

        elif isinstance(node.binary_op,
                        (AsmBitShiftLeft, AsmBitShiftRight)):
            if isinstance(node.src, AsmImm) and \
               node.src.is_quad:
                fix_binary_from_quad_word_imm_to_any_instruction(node)
                
            if isinstance(node.src, (AsmStack, AsmData)) and \
               isinstance(node.dst, (AsmStack, AsmData)):
                fix_binary_shx_from_addr_to_addr_instruction(node)

        elif isinstance(node.binary_op, AsmMult):
            if isinstance(node.src, AsmImm) and \
               node.src.is_quad:
                fix_binary_from_quad_word_imm_to_any_instruction(node)
                
            if isinstance(node.dst, (AsmStack, AsmData)):
                fix_binary_imul_from_any_to_addr_instruction(node)


cdef void fix_idiv_from_imm_instruction(AsmIdiv node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_idiv_instruction(AsmIdiv node):
    if isinstance(node.src, AsmImm):
        fix_idiv_from_imm_instruction(node)


cdef void fix_div_from_imm_instruction(AsmDiv node):
    cdef AsmOperand src = node.src
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('R10'))
    cdef AssemblyType assembly_type = node.assembly_type
    node.src = dst
    # only for cython
    fix_instructions[-1] = node
    #
    fix_instructions.append(AsmMov(assembly_type, src, dst))
    swap_fix_instructions_back()


cdef void fix_div_instruction(AsmDiv node):
    if isinstance(node.src, AsmImm):
        fix_div_from_imm_instruction(node)


cdef void fix_instruction():
    if isinstance(fix_instructions[-1], AsmMov):
        fix_mov_instruction(fix_instructions[-1])

    elif isinstance(fix_instructions[-1], AsmMovSx):
        fix_mov_sx_instruction(fix_instructions[-1])

    elif isinstance(fix_instructions[-1], AsmMovZeroExtend):
        fix_mov_zero_extend_instruction(fix_instructions[-1])

    elif isinstance(fix_instructions[-1], AsmCvttsd2si):
        fix_cvttsd2si_instruction(fix_instructions[-1])

    elif isinstance(fix_instructions[-1], AsmCvtsi2sd):
        fix_cvtsi2sd_instruction(fix_instructions[-1])

    elif isinstance(fix_instructions[-1], AsmCmp):
        fix_cmp_instruction(fix_instructions[-1])

    elif isinstance(fix_instructions[-1], AsmPush):
        fix_push_instruction(fix_instructions[-1])

    elif isinstance(fix_instructions[-1], AsmBinary):
        fix_binary_instruction(fix_instructions[-1])

    elif isinstance(fix_instructions[-1], AsmIdiv):
        fix_idiv_instruction(fix_instructions[-1])

    elif isinstance(fix_instructions[-1], AsmDiv):
        fix_div_instruction(fix_instructions[-1])


cdef void fix_function_top_level(AsmFunction node):
    global counter
    global fix_instructions

    counter = 0
    pseudo_map.clear()
    fix_instructions = [allocate_stack_bytes(0)]

    cdef Py_ssize_t instruction
    for instruction in range(len(node.instructions)):
        replace_pseudo_registers(node.instructions[instruction])

        fix_instructions.append(node.instructions[instruction])
        node.instructions[instruction] = None

        fix_instruction()

    fix_allocate_stack_bytes()

    node.instructions.clear()
    node.instructions = fix_instructions


cdef void fix_static_variable_top_level(AsmStaticVariable node):
    pass


cdef void fix_top_level(AsmTopLevel node):
    if isinstance(node, AsmFunction):
        fix_function_top_level(node)
    elif isinstance(node, AsmStaticVariable):
        fix_static_variable_top_level(node)
    else:

        raise RuntimeError(
            "An error occurred in stack management, not all nodes were visited")


cdef void fix_program(AsmProgram node):
    cdef Py_ssize_t top_level
    for top_level in range(len(node.top_levels)):
        fix_top_level(node.top_levels[top_level])


cdef void fix_stack(AsmProgram asm_ast):

    fix_program(asm_ast)
