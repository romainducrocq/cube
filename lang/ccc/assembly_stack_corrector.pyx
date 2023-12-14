from ccc.assembly_asm_ast cimport TInt, AsmProgram, AsmFunctionDef, AsmFunction, AsmPseudo, AsmStack, AsmAllocStack
from ccc.assembly_asm_ast cimport AsmInstruction, AsmOperand, AsmImm, AsmMov, AsmPush, AsmCmp, AsmSetCC
from ccc.assembly_asm_ast cimport AsmUnary, AsmBinary, AsmAdd, AsmSub, AsmIdiv, AsmMult
from ccc.assembly_asm_ast cimport AsmBitAnd, AsmBitOr, AsmBitXor, AsmBitShiftLeft, AsmBitShiftRight
from ccc.assembly_register cimport REGISTER_KIND, generate_register


cdef int OFFSET = -4
cdef int counter = -1
cdef dict[str, int] pseudo_map = {}


cdef AsmStack replace_pseudo_register_stack(AsmPseudo node):
    global counter
    global pseudo_map

    if node.name.str_t not in pseudo_map:
        counter += OFFSET
        pseudo_map[node.name.str_t] = counter

    cdef value = TInt(pseudo_map[node.name.str_t])
    return AsmStack(value)


cdef AsmStack replace_operand_pseudo_register(AsmOperand node):
    return replace_pseudo_register_stack(node)


cdef void replace_mov_pseudo_registers(AsmMov node):
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


cdef void prepend_alloc_stack(list[AsmInstruction] instructions):
    cdef TInt value = TInt(-1 * counter)
    instructions.insert(0, AsmAllocStack(value))


cdef void correct_function_def(AsmFunctionDef node):

    cdef int i, k, l
    cdef int instruction
    cdef AsmOperand src_src
    cdef int count_insert = 0
    if isinstance(node, AsmFunction):
        l = len(node.instructions)
        for instruction in range(len(node.instructions)):
            k = l - instruction
            i = - (instruction + 1 + count_insert)
            replace_pseudo_registers(node.instructions[i])

            if isinstance(node.instructions[i], (AsmMov, AsmCmp)) and \
                    isinstance(node.instructions[i].src, AsmStack) and \
                    isinstance(node.instructions[i].dst, AsmStack):
                # mov | cmp (addr, addr)
                # $ movl addr1, addr2 ->
                #     $ movl addr1, reg
                #     $ movl reg  , addr2
                src_src = node.instructions[i].src
                node.instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
                node.instructions.insert(k - 1, AsmMov(src_src, node.instructions[i].src))
                count_insert += 1

            elif isinstance(node.instructions[i], AsmCmp) and \
                    isinstance(node.instructions[i].dst, AsmImm):
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
                        isinstance(node.instructions[i].src, AsmStack) and \
                        isinstance(node.instructions[i].dst, AsmStack)):
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
                        isinstance(node.instructions[i].src, AsmStack) and \
                        isinstance(node.instructions[i].dst, AsmStack):
                    # shl | shr (addr, addr)
                    # $ addl addr1, addr2 ->
                    #     $ movl addr1, reg
                    #     $ addl reg  , addr2
                    src_src = node.instructions[i].src
                    node.instructions[i].src = generate_register(REGISTER_KIND.get('Cx'))
                    node.instructions.insert(k - 1, AsmMov(src_src, node.instructions[i].src))
                    count_insert += 1

                elif isinstance(node.instructions[i].binary_op, AsmMult) and \
                        isinstance(node.instructions[i].dst, AsmStack):
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
                    isinstance(node.instructions[i].src, AsmImm):
                # idiv (imm)
                # $ idivl imm ->
                #     $ movl  imm, reg
                #     $ idivl reg
                src_src = node.instructions[i].src
                node.instructions[i].src = generate_register(REGISTER_KIND.get('R10'))
                node.instructions.insert(k - 1, AsmMov(src_src, node.instructions[i].src))
                count_insert += 1

        prepend_alloc_stack(node.instructions)

    else:

        raise RuntimeError(
            "An error occurred in stack management, not all nodes were visited")


cdef void init_correct_instructions():
    global counter
    counter = 0
    pseudo_map.clear()


cdef void correct_instructions(AsmProgram node):
    cdef int function_def
    for function_def in range(len(node.function_defs)):
        init_correct_instructions()
        correct_function_def(node.function_defs[function_def])


cdef void correct_stack(AsmProgram asm_ast):

    correct_instructions(asm_ast)
