from ccc.util_ast cimport ast_iter_child_nodes, ast_set_child_node
from ccc.assembly_asm_ast cimport AST, TInt, AsmProgram, AsmFunctionDef, AsmFunction, AsmPseudo, AsmStack, AsmAllocStack
from ccc.assembly_asm_ast cimport AsmInstruction, AsmOperand, AsmMov, AsmCmp, AsmImm, AsmBinary, AsmIdiv, AsmMult
from ccc.assembly_asm_ast cimport AsmAdd, AsmSub, AsmBitAnd, AsmBitOr, AsmBitXor, AsmBitShiftLeft, AsmBitShiftRight
from ccc.assembly_register cimport REGISTER_KIND, generate_register


cdef int offset = -4
cdef int counter = -1
cdef dict[str, int] pseudo_map = {}


cdef void replace_pseudo_registers(AST node):
    global counter
    global pseudo_map

    if counter == -1:
        counter = 0

    cdef int item
    cdef str attr
    cdef TInt value
    cdef AST child_node
    for child_node, attr, item in ast_iter_child_nodes(node):
        if isinstance(child_node, AsmPseudo):
            if child_node.name.str_t not in pseudo_map:
                counter += offset
                pseudo_map[child_node.name.str_t] = counter

            value = TInt(pseudo_map[child_node.name.str_t])
            ast_set_child_node(node, attr, item, AsmStack(value))

        else:
            replace_pseudo_registers(child_node)


cdef void prepend_alloc_stack(list[AsmInstruction] instructions):

    if counter == -1:
        raise RuntimeError(
            "An error occurred in stack management, stack was not allocated")

    cdef TInt value = TInt(-1 * counter)
    instructions.insert(0, AsmAllocStack(value))


cdef void correct_function_def(AsmFunctionDef node):

    cdef int e
    cdef int i
    cdef int size
    cdef AsmInstruction instruction
    cdef AsmOperand src_src
    if isinstance(node, AsmFunction):
        prepend_alloc_stack(node.instructions)

        size = len(node.instructions)
        for e, instruction in enumerate(reversed(node.instructions)):
            i = size - e
            # mov | cmp (addr, addr)
            # $ movl addr1, addr2 ->
            #     $ movl addr1, reg
            #     $ movl reg  , addr2
            if isinstance(instruction, (AsmMov, AsmCmp)) and \
                    isinstance(instruction.src, AsmStack) and isinstance(instruction.dst, AsmStack):
                src_src = instruction.src
                instruction.src = generate_register(REGISTER_KIND.get('R10'))
                node.instructions.insert(i - 1, AsmMov(src_src, instruction.src))
            elif isinstance(instruction, AsmBinary):
                # add | sub | and | or | xor (addr, addr)
                # $ addl addr1, addr2 ->
                #     $ movl addr1, reg
                #     $ addl reg  , addr2
                if isinstance(instruction.binary_op, (AsmAdd, AsmSub, AsmBitAnd, AsmBitOr, AsmBitXor)) and \
                        isinstance(instruction.src, AsmStack) and isinstance(instruction.dst, AsmStack):
                    src_src = instruction.src
                    instruction.src = generate_register(REGISTER_KIND.get('R10'))
                    node.instructions.insert(i - 1, AsmMov(src_src, instruction.src))
                # shl | shr (addr, addr)
                # $ addl addr1, addr2 ->
                #     $ movl addr1, reg
                #     $ addl reg  , addr2
                elif isinstance(instruction.binary_op, (AsmBitShiftLeft, AsmBitShiftRight)) and \
                        isinstance(instruction.src, AsmStack) and isinstance(instruction.dst, AsmStack):
                    src_src = instruction.src
                    instruction.src = generate_register(REGISTER_KIND.get('Cx'))
                    node.instructions.insert(i - 1, AsmMov(src_src, instruction.src))
                # mul (_, addr)
                # $ imull imm, addr ->
                #     $ movl  addr, reg
                #     $ imull imm , reg
                #     $ movl  reg , addr
                elif isinstance(instruction.binary_op, AsmMult) and \
                        isinstance(instruction.dst, AsmStack):
                    src_src = instruction.dst
                    instruction.dst = generate_register(REGISTER_KIND.get('R11'))
                    node.instructions.insert(i - 1, AsmMov(src_src, instruction.dst))
                    node.instructions.insert(i + 1, AsmMov(instruction.dst, src_src))
            # idiv (imm)
            # $ idivl imm ->
            #     $ movl  imm, reg
            #     $ idivl reg
            elif isinstance(instruction, AsmIdiv) and \
                    isinstance(instruction.src, AsmImm):
                src_src = instruction.src
                instruction.src = generate_register(REGISTER_KIND.get('R10'))
                node.instructions.insert(i - 1, AsmMov(src_src, instruction.src))
            # $ cmpl reg1, imm ->
            #     $ movl imm , reg2
            #     $ cmpl reg1, reg2
            elif isinstance(instruction, AsmCmp) and \
                    isinstance(instruction.dst, AsmImm):
                src_src = instruction.dst
                instruction.dst = generate_register(REGISTER_KIND.get('R11'))
                node.instructions.insert(i - 1, AsmMov(src_src, instruction.dst))

    else:

        raise RuntimeError(
            "An error occurred in stack management, not all nodes were visited")


cdef void correct_instructions(AsmProgram node):
    correct_function_def(node.function_def)


cdef generate_stack(AsmProgram asm_ast):
    global counter
    global pseudo_map
    counter = -1
    pseudo_map = {}

    replace_pseudo_registers(asm_ast)

    correct_instructions(asm_ast)
