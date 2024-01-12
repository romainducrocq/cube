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
        if node.name.str_t in backend_symbol_table and \
           backend_symbol_table[node.name.str_t].is_static:
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
    cdef AsmOperand src = AsmImm(TIdentifier(str(byte)))
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    return AsmBinary(binary_op, assembly_type, src, dst)


cdef AsmBinary deallocate_stack_bytes(int32 byte):
    cdef AsmBinaryOp binary_op = AsmAdd()
    cdef AssemblyType assembly_type = QuadWord()
    cdef AsmOperand src = AsmImm(TIdentifier(str(byte)))
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    return AsmBinary(binary_op, assembly_type, src, dst)


cdef list[AsmInstruction] fun_instructions = []


cdef void prepend_alloc_stack():
    cdef int32 byte = -1 * counter

    if byte % 8 != 0:

        raise RuntimeError(
            f"An error occurred in function stack allocation, stack alignment {byte} is not a multiple of 8")

    fun_instructions.insert(0, allocate_stack_bytes(byte))


cdef void correct_any_from_addr_to_addr_instruction(Py_ssize_t i, Py_ssize_t k):
    # mov | cmp | add | sub | and | or | xor (addr, addr)
    # $ mov addr1, addr2 ->
    #     $ mov addr1, reg
    #     $ mov reg  , addr2
    cdef AsmOperand src_src = fun_instructions[i].src
    fun_instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
    fun_instructions.insert(k - 1, AsmMov(fun_instructions[i].assembly_type,
                                          src_src, fun_instructions[i].src))


cdef void correct_double_mov_from_addr_to_addr_instructions(Py_ssize_t i, Py_ssize_t k):
    # mov<q> (_, addr)
    # $ mov<q> addr1, addr2 ->
    #     $ mov    addr1, reg
    #     $ mov<q> reg  , addr2
    cdef AsmOperand src_src = fun_instructions[i].src
    fun_instructions[i].src = generate_register(REGISTER_KIND.get('Xmm14'))
    fun_instructions.insert(k - 1, AsmMov(fun_instructions[i].assembly_type,
                                          src_src, fun_instructions[i].src))


cdef void correct_mov_sx_from_imm_to_any_instructions(Py_ssize_t i, Py_ssize_t k):
    # movsx (imm, _)
    # $ movsx imm, _ ->
    #     $ mov   imm, reg
    #     $ movsx reg, _
    cdef AsmOperand src_src = fun_instructions[i].src
    fun_instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
    fun_instructions.insert(k - 1, AsmMov(LongWord(),
                                          src_src, fun_instructions[i].src))


cdef void correct_mov_sx_zero_extend_from_any_to_addr_instructions(Py_ssize_t i, Py_ssize_t k):
    # movsx | mov0x (_, addr)
    # $ movsx _, addr ->
    #     $ movsx _  , reg
    #     $ mov   reg, addr
    cdef AsmOperand src_dst = fun_instructions[i].dst
    fun_instructions[i].dst = generate_register(REGISTER_KIND.get('R11'))
    fun_instructions.insert(k, AsmMov(QuadWord(),
                                      fun_instructions[i].dst, src_dst))


cdef void correct_mov_zero_extend_from_any_to_any_instructions(Py_ssize_t i):
    fun_instructions[i] = AsmMov(LongWord(),
                                 fun_instructions[i].src, fun_instructions[i].dst)


cdef void correct_cvttsd2si_from_any_to_addr_instructions(Py_ssize_t i, Py_ssize_t k):
    # cvttsd2si (_, addr)
    # $ cvttsd2si _, addr ->
    #     $ cvttsd2si _  , reg
    #     $ mov       reg, addr
    cdef AsmOperand src_dst = fun_instructions[i].dst
    fun_instructions[i].dst = generate_register(REGISTER_KIND.get('R11'))
    fun_instructions.insert(k, AsmMov(fun_instructions[i].assembly_type,
                                      fun_instructions[i].dst, src_dst))


cdef void correct_cvtsi2sd_from_imm_to_any_instructions(Py_ssize_t i, Py_ssize_t k):
    # cvtsi2sd (imm, _)
    # $ cvtsi2sd imm, _ ->
    #     $ mov      imm, reg
    #     $ cvtsi2sd reg, _
    cdef AsmOperand src_src = fun_instructions[i].src
    fun_instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
    fun_instructions.insert(k - 1, AsmMov(fun_instructions[i].assembly_type,
                                          src_src, fun_instructions[i].src))


cdef void correct_cvtsi2sd_binary_from_any_to_addr_instructions(Py_ssize_t i, Py_ssize_t k):
    # cvtsi2sd | add<q> | sub<q> | mul<q> | div<q> | xor<q> (_, addr)
    # $ cvtsi2sd _, addr ->
    #     $ cvtsi2sd _  , reg
    #     $ mov      reg, addr
    cdef AsmOperand src_dst = fun_instructions[i].dst
    fun_instructions[i].dst = generate_register(REGISTER_KIND.get('Xmm15'))
    fun_instructions.insert(k, AsmMov(BackendDouble(),
                                      fun_instructions[i].dst, src_dst))


cdef void correct_cmp_from_any_to_imm_instructions(Py_ssize_t i, Py_ssize_t k):
    # cmp (_, imm)
    # $ cmp reg1, imm ->
    #     $ mov imm , reg2
    #     $ cmp reg1, reg2
    cdef AsmOperand src_dst = fun_instructions[i].dst
    fun_instructions[i].dst = generate_register(REGISTER_KIND.get('R11'))
    fun_instructions.insert(k - 1, AsmMov(fun_instructions[i].assembly_type,
                                          src_dst, fun_instructions[i].dst))


cdef correct_double_cmp_from_any_to_addr_instructions(Py_ssize_t i, Py_ssize_t k):
    # cmp<d> (_, addr)
    # $ cmp<d> _, addr ->
    #     $ mov    addr, reg
    #     $ cmp<d> _   , reg
    cdef AsmOperand dst_dst = fun_instructions[i].dst
    fun_instructions[i].dst = generate_register(REGISTER_KIND.get('Xmm15'))
    fun_instructions.insert(k - 1, AsmMov(BackendDouble(),
                                          dst_dst, fun_instructions[i].dst))


cdef void correct_shl_shr_from_addr_to_addr(Py_ssize_t i, Py_ssize_t k):
    # shl | shr (addr, addr)
    # $ shl addr1, addr2 ->
    #     $ mov addr1, reg
    #     $ shl reg, addr2
    cdef AsmOperand src_src = fun_instructions[i].src
    fun_instructions[i].src = generate_register(REGISTER_KIND.get('Cx'))
    fun_instructions.insert(k - 1, AsmMov(fun_instructions[i].assembly_type,
                                          src_src, fun_instructions[i].src))


cdef void correct_mul_from_any_to_addr(Py_ssize_t i, Py_ssize_t k):
    # imul (_, addr)
    # $ imul imm, addr ->
    #     $ mov  addr, reg
    #     $ imul imm , reg
    #     $ mov  reg , addr
    cdef AsmOperand src_src = fun_instructions[i].dst
    cdef AsmOperand dst_dst = fun_instructions[i].dst
    fun_instructions[i].dst = generate_register(REGISTER_KIND.get('R11'))
    fun_instructions.insert(k - 1, AsmMov(fun_instructions[i].assembly_type,
                                          src_src, fun_instructions[i].dst))
    fun_instructions.insert(k + 1, AsmMov(fun_instructions[i].assembly_type,
                                          fun_instructions[i].dst, dst_dst))


cdef void correct_div_from_imm(Py_ssize_t i, Py_ssize_t k):
    # idiv | div (imm)
    # $ idiv imm ->
    #     $ mov  imm, reg
    #     $ idiv reg
    cdef AsmOperand src_src = fun_instructions[i].src
    fun_instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
    fun_instructions.insert(k - 1, AsmMov(fun_instructions[i].assembly_type,
                                          src_src, fun_instructions[i].src))


cdef void correct_any_from_quad_word_imm_to_any(Py_ssize_t i, Py_ssize_t k):
    # mov | cmp | push | add | sub | mul (q imm, _)
    # $ mov imm<q>, _ ->
    #     $ mov imm<q>, reg
    #     $ mov reg   , _
    cdef AsmOperand src_src = fun_instructions[i].src
    fun_instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
    fun_instructions.insert(k - 1, AsmMov(QuadWord(),
                                          src_src, fun_instructions[i].src))


cdef bint is_from_long_imm_instruction(Py_ssize_t i):
    return isinstance(fun_instructions[i].src, AsmImm) and \
            int(fun_instructions[i].src.value.str_t) > 2147483647


cdef bint is_from_imm_instruction(Py_ssize_t i):
    return isinstance(fun_instructions[i].src, AsmImm)


cdef bint is_to_imm_instruction(Py_ssize_t i):
    return isinstance(fun_instructions[i].dst, AsmImm)


cdef bint is_from_addr_instruction(Py_ssize_t i):
    return isinstance(fun_instructions[i].src, (AsmStack, AsmData))


cdef bint is_to_addr_instruction(Py_ssize_t i):
    return isinstance(fun_instructions[i].dst, (AsmStack, AsmData))


cdef bint is_from_addr_to_addr_instruction(Py_ssize_t i):
    return is_from_addr_instruction(i) and \
           is_to_addr_instruction(i)


cdef void correct_function_top_level(AsmFunction node):
    global fun_instructions
    fun_instructions = node.instructions

    cdef Py_ssize_t i, k
    cdef Py_ssize_t instruction
    cdef Py_ssize_t count_insert = 0
    cdef Py_ssize_t l = len(fun_instructions)
    for instruction in range(l):
        k = l - instruction
        i = - (instruction + 1 + count_insert)

        replace_pseudo_registers(fun_instructions[i])

        if isinstance(fun_instructions[i], AsmMov):
            if isinstance(fun_instructions[i].assembly_type, BackendDouble):
                if is_to_addr_instruction(i):
                    correct_double_mov_from_addr_to_addr_instructions(i, k)
                    count_insert += 1
            else:
                if is_from_long_imm_instruction(i):
                    correct_any_from_quad_word_imm_to_any(i, k)
                    count_insert += 1

                if is_from_addr_to_addr_instruction(i):
                    correct_any_from_addr_to_addr_instruction(i, k)
                    count_insert += 1

        elif isinstance(fun_instructions[i], AsmMovSx):
            if is_from_imm_instruction(i):
                correct_mov_sx_from_imm_to_any_instructions(i, k)
                k += 1
                count_insert += 1

            if is_to_addr_instruction(i):
                correct_mov_sx_zero_extend_from_any_to_addr_instructions(i, k)
                count_insert += 1

        elif isinstance(fun_instructions[i], AsmMovZeroExtend):
            correct_mov_zero_extend_from_any_to_any_instructions(i)

            if is_to_addr_instruction(i):
                correct_mov_sx_zero_extend_from_any_to_addr_instructions(i, k)
                count_insert += 1

        elif isinstance(fun_instructions[i], AsmCvttsd2si):
            if is_to_addr_instruction(i):
                correct_cvttsd2si_from_any_to_addr_instructions(i, k)
                count_insert += 1

        elif isinstance(fun_instructions[i], AsmCvtsi2sd):
            if is_from_imm_instruction(i):
                correct_cvtsi2sd_from_imm_to_any_instructions(i, k)
                k += 1
                count_insert += 1

            if is_to_addr_instruction(i):
                correct_cvtsi2sd_binary_from_any_to_addr_instructions(i, k)
                count_insert += 1

        elif isinstance(fun_instructions[i], AsmCmp):
            if isinstance(fun_instructions[i].assembly_type, BackendDouble):
                if is_to_addr_instruction(i):
                    correct_double_cmp_from_any_to_addr_instructions(i, k)
                    count_insert += 1
            else:
                if is_from_long_imm_instruction(i):
                    correct_any_from_quad_word_imm_to_any(i, k)
                    count_insert += 1

                if is_from_addr_to_addr_instruction(i):
                    correct_any_from_addr_to_addr_instruction(i, k)
                    count_insert += 1

                elif is_to_imm_instruction(i):
                    correct_cmp_from_any_to_imm_instructions(i, k)
                    count_insert += 1

        elif isinstance(fun_instructions[i], AsmPush):
            if is_from_long_imm_instruction(i):
                correct_any_from_quad_word_imm_to_any(i, k)
                count_insert += 1

        elif isinstance(fun_instructions[i], AsmBinary):
            if isinstance(fun_instructions[i].assembly_type, BackendDouble):
                if is_to_addr_instruction(i):
                    correct_cvtsi2sd_binary_from_any_to_addr_instructions(i, k)
                    count_insert += 1
            else:
                if isinstance(fun_instructions[i].binary_op,
                              (AsmAdd, AsmSub, AsmBitAnd, AsmBitOr, AsmBitXor)):
                    if is_from_long_imm_instruction(i):
                        correct_any_from_quad_word_imm_to_any(i, k)
                        count_insert += 1

                    if is_from_addr_to_addr_instruction(i):
                        correct_any_from_addr_to_addr_instruction(i, k)
                        count_insert += 1

                elif isinstance(fun_instructions[i].binary_op,
                                (AsmBitShiftLeft, AsmBitShiftRight)):
                    if is_from_long_imm_instruction(i):
                        correct_any_from_quad_word_imm_to_any(i, k)
                        count_insert += 1

                    if is_from_addr_to_addr_instruction(i):
                        correct_shl_shr_from_addr_to_addr(i, k)
                        count_insert += 1

                elif isinstance(fun_instructions[i].binary_op, AsmMult):
                    if is_from_long_imm_instruction(i):
                        correct_any_from_quad_word_imm_to_any(i, k)
                        k += 1
                        count_insert += 1

                    if is_to_addr_instruction(i):
                        correct_mul_from_any_to_addr(i, k)
                        count_insert += 2

        elif isinstance(fun_instructions[i], (AsmIdiv, AsmDiv)):
            if is_from_imm_instruction(i):
                correct_div_from_imm(i, k)
                count_insert += 1

    prepend_alloc_stack()


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
