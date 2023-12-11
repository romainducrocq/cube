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

    cdef int e, i, l
    cdef AsmInstruction instruction
    cdef AsmOperand src_src
    if isinstance(node, AsmFunction):
        l = len(node.instructions)
        for e, instruction in enumerate(reversed(node.instructions)):
            i = l - e
            replace_pseudo_registers(instruction)

            if isinstance(instruction, (AsmMov, AsmCmp)) and \
                    isinstance(instruction.src, AsmStack) and isinstance(instruction.dst, AsmStack):
                # mov | cmp (addr, addr)
                # $ movl addr1, addr2 ->
                #     $ movl addr1, reg
                #     $ movl reg  , addr2
                src_src = instruction.src
                instruction.src = generate_register(REGISTER_KIND.get('R10'))
                node.instructions.insert(i - 1, AsmMov(src_src, instruction.src))

            elif isinstance(instruction, AsmCmp) and \
                    isinstance(instruction.dst, AsmImm):
                # $ cmpl reg1, imm ->
                #     $ movl imm , reg2
                #     $ cmpl reg1, reg2
                src_src = instruction.dst
                instruction.dst = generate_register(REGISTER_KIND.get('R11'))
                node.instructions.insert(i - 1, AsmMov(src_src, instruction.dst))

            elif isinstance(instruction, AsmBinary):

                if isinstance(instruction.binary_op, (AsmAdd, AsmSub, AsmBitAnd, AsmBitOr, AsmBitXor)) and \
                        isinstance(instruction.src, AsmStack) and isinstance(instruction.dst, AsmStack):
                    # add | sub | and | or | xor (addr, addr)
                    # $ addl addr1, addr2 ->
                    #     $ movl addr1, reg
                    #     $ addl reg  , addr2
                    src_src = instruction.src
                    instruction.src = generate_register(REGISTER_KIND.get('R10'))
                    node.instructions.insert(i - 1, AsmMov(src_src, instruction.src))

                elif isinstance(instruction.binary_op, (AsmBitShiftLeft, AsmBitShiftRight)) and \
                        isinstance(instruction.src, AsmStack) and isinstance(instruction.dst, AsmStack):
                    # shl | shr (addr, addr)
                    # $ addl addr1, addr2 ->
                    #     $ movl addr1, reg
                    #     $ addl reg  , addr2
                    src_src = instruction.src
                    instruction.src = generate_register(REGISTER_KIND.get('Cx'))
                    node.instructions.insert(i - 1, AsmMov(src_src, instruction.src))

                elif isinstance(instruction.binary_op, AsmMult) and \
                        isinstance(instruction.dst, AsmStack):
                    # mul (_, addr)
                    # $ imull imm, addr ->
                    #     $ movl  addr, reg
                    #     $ imull imm , reg
                    #     $ movl  reg , addr
                    src_src = instruction.dst
                    instruction.dst = generate_register(REGISTER_KIND.get('R11'))
                    node.instructions.insert(i - 1, AsmMov(src_src, instruction.dst))
                    node.instructions.insert(i + 1, AsmMov(instruction.dst, src_src))

            elif isinstance(instruction, AsmIdiv) and \
                    isinstance(instruction.src, AsmImm):
                # idiv (imm)
                # $ idivl imm ->
                #     $ movl  imm, reg
                #     $ idivl reg
                src_src = instruction.src
                instruction.src = generate_register(REGISTER_KIND.get('R10'))
                node.instructions.insert(i - 1, AsmMov(src_src, instruction.src))

        prepend_alloc_stack(node.instructions)

    else:

        raise RuntimeError(
            "An error occurred in stack management, not all nodes were visited")


cdef void init_correct_instructions():
    global counter
    global pseudo_map
    counter = 0
    pseudo_map = {}


cdef void correct_instructions(AsmProgram node):
    cdef int function_def
    for function_def in range(len(node.function_defs)):
        init_correct_instructions()
        correct_function_def(node.function_defs[function_def])


cdef void correct_stack(AsmProgram asm_ast):

    correct_instructions(asm_ast)
