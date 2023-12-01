from ccc.intermediate_tac_ast cimport *
from ccc.assembly_asm_ast cimport *
from ccc.assembly_register cimport REGISTER_KIND, generate_register
from ccc.assembly_stack cimport generate_stack


cdef TIdentifier generate_identifier(TIdentifier node):
    # <identifier> = Built-in identifier type
    return TIdentifier(node.str_t)


cdef TInt generate_int(TInt node):
    # <int> = Built-in int type
    return TInt(node.int_t)


cdef AsmOperand generate_operand(TacValue node):
    # operand = Imm(int) | Reg(reg) | Pseudo(identifier) | Stack(int)
    cdef TInt value
    if isinstance(node, TacConstant):
        value = generate_int(node.value)
        return AsmImm(value)
    cdef TIdentifier
    if isinstance(node, TacVariable):
        identifier = generate_identifier(node.name)
        return AsmPseudo(identifier)

    raise RuntimeError(
        "An error occurred in assembly generation, not all nodes were visited")


cdef AsmCondCode generate_condition_code(TacBinaryOp node):
    # cond_code = E | NE | G | GE | L | LE
    if isinstance(node, TacEqual):
        return AsmE()
    if isinstance(node, TacNotEqual):
        return AsmNE()
    if isinstance(node, TacLessThan):
        return AsmL()
    if isinstance(node, TacLessOrEqual):
        return AsmLE()
    if isinstance(node, TacGreaterThan):
        return AsmG()
    if isinstance(node, TacGreaterOrEqual):
        return AsmGE()

    raise RuntimeError(
        "An error occurred in assembly generation, not all nodes were visited")


cdef AsmBinaryOp generate_binary_op(TacBinaryOp node):
    # binary_operator = Add | Sub | Mult | BitAnd | BitOr | BitXor | BitShiftLeft | BitShiftRight
    if isinstance(node, TacAdd):
        return AsmAdd()
    if isinstance(node, TacSubtract):
        return AsmSub()
    if isinstance(node, TacMultiply):
        return AsmMult()
    if isinstance(node, TacBitAnd):
        return AsmBitAnd()
    if isinstance(node, TacBitOr):
        return AsmBitOr()
    if isinstance(node, TacBitXor):
        return AsmBitXor()
    if isinstance(node, TacBitShiftLeft):
        return AsmBitShiftLeft()
    if isinstance(node, TacBitShiftRight):
        return AsmBitShiftRight()

    raise RuntimeError(
        "An error occurred in assembly generation, not all nodes were visited")


cdef AsmUnaryOp generate_unary_op(TacUnaryOp node):
    # unary_operator = Not | Neg
    if isinstance(node, TacComplement):
        return AsmNot()
    if isinstance(node, TacNegate):
        return AsmNeg()

    raise RuntimeError(
        "An error occurred in assembly generation, not all nodes were visited")


cdef list[AsmInstruction] instructions = []


cdef void generate_label_instructions(TacLabel node):
    cdef TIdentifier name = generate_identifier(node.name)
    instructions.append(AsmLabel(name))


cdef void generate_jump_instructions(TacJump node):
    cdef TIdentifier target = generate_identifier(node.target)
    instructions.append(AsmJmp(target))


cdef void generate_return_instructions(TacReturn node):
    cdef AsmOperand src = generate_operand(node.val)
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Ax'))
    instructions.append(AsmMov(src, dst))
    instructions.append(AsmRet())


cdef void generate_copy_instructions(TacCopy node):
    cdef AsmOperand src = generate_operand(node.src)
    cdef AsmOperand dst = generate_operand(node.dst)
    instructions.append(AsmMov(src, dst))


cdef void generate_jump_if_zero_instructions(TacJumpIfZero node):
    cdef AsmOperand imm_zero = AsmImm(TInt(0))
    cdef AsmCondCode cond_code = generate_condition_code(TacEqual())
    cdef TIdentifier target = generate_identifier(node.target)
    cdef AsmOperand condition = generate_operand(node.condition)
    instructions.append(AsmCmp(imm_zero, condition))
    instructions.append(AsmJmpCC(cond_code, target))


cdef void generate_jump_if_not_zero_instructions(TacJumpIfNotZero node):
    cdef AsmOperand imm_zero = AsmImm(TInt(0))
    cdef AsmCondCode cond_code = generate_condition_code(TacNotEqual())
    cdef TIdentifier target = generate_identifier(node.target)
    cdef AsmOperand condition = generate_operand(node.condition)
    instructions.append(AsmCmp(imm_zero, condition))
    instructions.append(AsmJmpCC(cond_code, target))


cdef void generate_unary_operator_conditional_instructions(TacUnary node):
    cdef imm_zero = AsmImm(TInt(0))
    cdef cond_code = generate_condition_code(TacEqual())
    cdef src = generate_operand(node.src)
    cdef cmp_dst = generate_operand(node.dst)
    instructions.append(AsmCmp(imm_zero, src))
    instructions.append(AsmMov(imm_zero, cmp_dst))
    instructions.append(AsmSetCC(cond_code, cmp_dst))


cdef void generate_unary_operator_arithmetic_instructions(TacUnary node):
    cdef AsmUnaryOp unary_op = generate_unary_op(node.unary_op)
    cdef AsmOperand src = generate_operand(node.src)
    cdef AsmOperand src_dst = generate_operand(node.dst)
    instructions.append(AsmMov(src, src_dst))
    instructions.append(AsmUnary(unary_op, src_dst))


cdef void generate_binary_operator_conditional_instructions(TacBinary node):
    cdef imm_zero = AsmImm(TInt(0))
    cdef cond_code = generate_condition_code(node.binary_op)
    cdef src1 = generate_operand(node.src1)
    cdef src2 = generate_operand(node.src2)
    cdef cmp_dst = generate_operand(node.dst)
    instructions.append(AsmCmp(src2, src1))
    instructions.append(AsmMov(imm_zero, cmp_dst))
    instructions.append(AsmSetCC(cond_code, cmp_dst))


cdef void generate_binary_operator_arithmetic_instructions(TacBinary node):
    cdef AsmBinaryOp binary_op = generate_binary_op(node.binary_op)
    cdef AsmOperand src1 = generate_operand(node.src1)
    cdef AsmOperand src2 = generate_operand(node.src2)
    cdef AsmOperand src1_dst = generate_operand(node.dst)
    instructions.append(AsmMov(src1, src1_dst))
    instructions.append(AsmBinary(binary_op, src2, src1_dst))


cdef void generate_binary_operator_arithmetic_divide_instructions(TacBinary node):
    cdef AsmOperand src1 = generate_operand(node.src1)
    cdef AsmOperand src2 = generate_operand(node.src2)
    cdef AsmOperand dst = generate_operand(node.dst)
    cdef AsmOperand src1_dst = generate_register(REGISTER_KIND.get('Ax'))
    cdef AsmOperand dst_src = generate_register(REGISTER_KIND.get('Ax'))
    instructions.append(AsmMov(src1, src1_dst))
    instructions.append(AsmCdq())
    instructions.append(AsmIdiv(src2))
    instructions.append(AsmMov(dst_src, dst))


cdef void generate_binary_operator_arithmetic_remainder_instructions(TacBinary node):
    cdef AsmOperand src1 = generate_operand(node.src1)
    cdef AsmOperand src2 = generate_operand(node.src2)
    cdef AsmOperand dst = generate_operand(node.dst)
    cdef AsmOperand src1_dst = generate_register(REGISTER_KIND.get('Ax'))
    cdef AsmOperand dst_src = generate_register(REGISTER_KIND.get('Dx'))
    instructions.append(AsmMov(src1, src1_dst))
    instructions.append(AsmCdq())
    instructions.append(AsmIdiv(src2))
    instructions.append(AsmMov(dst_src, dst))


cdef void generate_instructions(TacInstruction node):
    if isinstance(node, TacLabel):
        generate_label_instructions(node)
        return
    if isinstance(node, TacJump):
        generate_jump_instructions(node)
        return
    if isinstance(node, TacReturn):
        generate_return_instructions(node)
        return
    if isinstance(node, TacCopy):
        generate_copy_instructions(node)
        return
    if isinstance(node, TacJumpIfZero):
        generate_jump_if_zero_instructions(node)
        return
    if isinstance(node, TacJumpIfNotZero):
        generate_jump_if_not_zero_instructions(node)
        return
    if isinstance(node, TacUnary):
        if isinstance(node.unary_op, TacNot):
            generate_unary_operator_conditional_instructions(node)
            return
        if isinstance(node.unary_op, (TacComplement, TacNegate)):
            generate_unary_operator_arithmetic_instructions(node)
            return

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")

    if isinstance(node, TacBinary):
        if isinstance(node.binary_op, (TacEqual, TacNotEqual, TacLessThan, TacLessOrEqual, TacGreaterThan,
                                       TacGreaterOrEqual)):
            generate_binary_operator_conditional_instructions(node)
            return
        if isinstance(node.binary_op, (TacAdd, TacSubtract, TacMultiply, TacBitAnd, TacBitOr, TacBitXor,
                                       TacBitShiftLeft, TacBitShiftRight)):
            generate_binary_operator_arithmetic_instructions(node)
            return
        if isinstance(node.binary_op, TacDivide):
            generate_binary_operator_arithmetic_divide_instructions(node)
            return
        if isinstance(node.binary_op, TacRemainder):
            generate_binary_operator_arithmetic_remainder_instructions(node)
            return

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")

    raise RuntimeError(
        "An error occurred in assembly generation, not all nodes were visited")


cdef void generate_list_instructions(list[TacInstruction] list_node):
    # instruction = Mov(operand src, operand dst) | Unary(unary_operator, operand) | Cmp(operand, operand)
    #             | Idiv(operand) | Cdq | Jmp(identifier) | JmpCC(cond_code, identifier)
    #             | SetCC(cond_code, operand) | Label(identifier) | AllocateStack(int) | Ret
    global instructions
    instructions = []

    cdef TacInstruction item_node
    for item_node in list_node:
        generate_instructions(item_node)


cdef AsmFunctionDef generate_function_def(TacFunctionDef node):
    # function_definition = Function(identifier name, instruction* instructions)
    cdef TIdentifier name
    if isinstance(node, TacFunction):
        name = generate_identifier(node.name)
        generate_list_instructions(node.body)
        return AsmFunction(name, instructions)

    raise RuntimeError(
        "An error occurred in assembly generation, not all nodes were visited")


cdef AsmProgram generate_program(TacProgram node):
    # program = Program(function_definition)
    cdef AsmFunctionDef function_def = generate_function_def(node.function_def)
    return AsmProgram(function_def)


cdef AsmProgram assembly_generation(TacProgram tac_ast):

    cdef AsmProgram asm_ast = generate_program(tac_ast)

    if not asm_ast:
        raise RuntimeError(
            "An error occurred in assembly generation, ASM was not generated")

    generate_stack(asm_ast)

    return asm_ast
