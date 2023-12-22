from ccc.abc_builtin_ast cimport copy_identifier

from ccc.assembly_asm_ast cimport TIdentifier, TInt, AsmProgram, AsmTopLevel, AsmFunction, AsmStaticVariable
from ccc.assembly_asm_ast cimport AsmInstruction, AsmImmInt, AsmImmLong, AsmMov, AsmMovSx, AsmPush, AsmCmp, AsmSetCC
from ccc.assembly_asm_ast cimport AsmUnary, AsmBinary, AsmBinaryOp, AsmAdd, AsmSub, AsmIdiv, AsmMult
from ccc.assembly_asm_ast cimport AsmOperand, AsmPseudo, AsmStack, AsmData
from ccc.assembly_asm_ast cimport AsmBitAnd, AsmBitOr, AsmBitXor, AsmBitShiftLeft, AsmBitShiftRight
from ccc.assembly_register cimport REGISTER_KIND, generate_register
from ccc.assembly_backend_symbol_table cimport backend_symbol_table, AssemblyType, LongWord, QuadWord

from ccc.util_ctypes cimport int32


cdef int32 OFFSET_LONG_WORD = -4
cdef int32 OFFSET_QUAD_WORD = -8
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
        counter += OFFSET_LONG_WORD
    elif isinstance(assembly_type, QuadWord):
        counter += OFFSET_QUAD_WORD



cdef void align_offset_pseudo_register(AssemblyType assembly_type):
    global counter

    if isinstance(assembly_type, LongWord):
        counter += OFFSET_LONG_WORD



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


cdef void replace_pseudo_registers(AsmInstruction node):
    if isinstance(node, AsmMov):
        replace_mov_pseudo_registers(node)
    elif isinstance(node, AsmMovSx):
        replace_mov_sx_pseudo_registers(node)
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


cdef AsmBinary allocate_stack_bytes(int32 byte):
    cdef AsmBinaryOp binary_op = AsmSub()
    cdef AssemblyType assembly_type = QuadWord()
    cdef AsmOperand src = AsmImmInt(TInt(byte))
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    return AsmBinary(binary_op, assembly_type, src, dst)


cdef AsmBinary deallocate_stack_bytes(int32 byte):
    cdef AsmBinaryOp binary_op = AsmAdd()
    cdef AssemblyType assembly_type = QuadWord()
    cdef AsmOperand src = AsmImmInt(TInt(byte))
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    return AsmBinary(binary_op, assembly_type, src, dst)


cdef void prepend_alloc_stack(list[AsmInstruction] instructions):
    cdef int32 byte = -1 * counter

    if byte % 8 != 0:

        raise RuntimeError(
            f"An error occurred in function stack allocation, stack alignment {byte} is not a multiple of 8")

    instructions.insert(0, allocate_stack_bytes(byte))


cdef void correct_function_top_level(AsmFunction node):
    cdef Py_ssize_t i, k
    cdef Py_ssize_t instruction
    cdef Py_ssize_t count_insert = 0
    cdef Py_ssize_t l = len(node.instructions)
    cdef AsmOperand src_src
    for instruction in range(len(node.instructions)):
        k = l - instruction
        i = - (instruction + 1 + count_insert)
        replace_pseudo_registers(node.instructions[i])

        if isinstance(node.instructions[i], (AsmMov, AsmCmp)) and \
                isinstance(node.instructions[i].src, (AsmStack, AsmData)) and \
                isinstance(node.instructions[i].dst, (AsmStack, AsmData)):
            # mov | cmp (addr, addr)
            # $ movl addr1, addr2 ->
            #     $ movl addr1, reg
            #     $ movl reg  , addr2
            src_src = node.instructions[i].src
            node.instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
            node.instructions.insert(k - 1, AsmMov(src_src, node.instructions[i].src))
            count_insert += 1

        elif isinstance(node.instructions[i], AsmCmp) and \
                isinstance(node.instructions[i].dst, (AsmImmInt, AsmImmLong)):
            # $ cmpl reg1, imm ->
            #     $ movl imm , reg2
            #     $ cmpl reg1, reg2
            src_src = node.instructions[i].dst
            node.instructions[i].dst = generate_register(REGISTER_KIND.get('R11'))
            node.instructions.insert(k - 1, AsmMov(src_src, node.instructions[i].dst))
            count_insert += 1

        elif isinstance(node.instructions[i], AsmBinary):

            if (isinstance(node.instructions[i].binary_op,
                           (AsmAdd, AsmSub, AsmBitAnd, AsmBitOr, AsmBitXor)) and \
                    isinstance(node.instructions[i].src, (AsmStack, AsmData)) and \
                    isinstance(node.instructions[i].dst, (AsmStack, AsmData))):
                # add | sub | and | or | xor (addr, addr)
                # $ addl addr1, addr2 ->
                #     $ movl addr1, reg
                #     $ addl reg  , addr2
                src_src = node.instructions[i].src
                node.instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
                node.instructions.insert(k - 1, AsmMov(src_src, node.instructions[i].src))
                count_insert += 1

            elif isinstance(node.instructions[i].binary_op,
                            (AsmBitShiftLeft, AsmBitShiftRight)) and \
                    isinstance(node.instructions[i].src, (AsmStack, AsmData)) and \
                    isinstance(node.instructions[i].dst, (AsmStack, AsmData)):
                # shl | shr (addr, addr)
                # $ addl addr1, addr2 ->
                #     $ movl addr1, reg
                #     $ addl reg  , addr2
                src_src = node.instructions[i].src
                node.instructions[i].src = generate_register(REGISTER_KIND.get('Cx'))
                node.instructions.insert(k - 1, AsmMov(src_src, node.instructions[i].src))
                count_insert += 1

            elif isinstance(node.instructions[i].binary_op, AsmMult) and \
                    isinstance(node.instructions[i].dst, (AsmStack, AsmData)):
                # mul (_, addr)
                # $ imull imm, addr ->
                #     $ movl  addr, reg
                #     $ imull imm , reg
                #     $ movl  reg , addr
                src_src = node.instructions[i].dst
                node.instructions[i].dst = generate_register(REGISTER_KIND.get('R11'))
                node.instructions.insert(k - 1, AsmMov(src_src, node.instructions[i].dst))
                node.instructions.insert(k + 1, AsmMov(node.instructions[i].dst, src_src))
                count_insert += 2

        elif isinstance(node.instructions[i], AsmIdiv) and \
                isinstance(node.instructions[i].src, (AsmImmInt, AsmImmLong)):
            # idiv (imm)
            # $ idivl imm ->
            #     $ movl  imm, reg
            #     $ idivl reg
            src_src = node.instructions[i].src
            node.instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
            node.instructions.insert(k - 1, AsmMov(src_src, node.instructions[i].src))
            count_insert += 1

    prepend_alloc_stack(node.instructions)


cdef void correct_variable_stack_top_level(AsmStaticVariable node):
    pass


cdef void correct_top_level(AsmTopLevel node):
    if isinstance(node, AsmFunction):
        correct_function_top_level(node)
    elif isinstance(node, AsmStaticVariable):
        correct_variable_stack_top_level(node)
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
