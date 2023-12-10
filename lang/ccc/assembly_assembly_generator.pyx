from ccc.intermediate_tac_ast cimport *
from ccc.assembly_asm_ast cimport *
from ccc.assembly_register cimport REGISTER_KIND, generate_register
# from ccc.assembly_stack_corrector cimport correct_stack


cdef TIdentifier generate_identifier(TIdentifier node):
    # <identifier> = Built-in identifier type
    return TIdentifier(node.str_t)


cdef TInt generate_int(TInt node):
    # <int> = Built-in int type
    return TInt(node.int_t)


cdef AsmImm generate_imm_operand(TacConstant node):
    cdef TInt value
    value = generate_int(node.value)
    return AsmImm(value)


cdef AsmPseudo generate_pseudo_operand(TacVariable node):
    cdef TIdentifier identifier
    identifier = generate_identifier(node.name)
    return AsmPseudo(identifier)


cdef AsmOperand generate_operand(TacValue node):
    # operand = Imm(int) | Reg(reg) | Pseudo(identifier) | Stack(int)
    if isinstance(node, TacConstant):
        return generate_imm_operand(node)
    elif isinstance(node, TacVariable):
        return generate_pseudo_operand(node)
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef AsmCondCode generate_condition_code(TacBinaryOp node):
    # cond_code = E | NE | G | GE | L | LE
    if isinstance(node, TacEqual):
        return AsmE()
    elif isinstance(node, TacNotEqual):
        return AsmNE()
    elif isinstance(node, TacLessThan):
        return AsmL()
    elif isinstance(node, TacLessOrEqual):
        return AsmLE()
    elif isinstance(node, TacGreaterThan):
        return AsmG()
    elif isinstance(node, TacGreaterOrEqual):
        return AsmGE()
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef AsmBinaryOp generate_binary_op(TacBinaryOp node):
    # binary_operator = Add | Sub | Mult | BitAnd | BitOr | BitXor | BitShiftLeft | BitShiftRight
    if isinstance(node, TacAdd):
        return AsmAdd()
    elif isinstance(node, TacSubtract):
        return AsmSub()
    elif isinstance(node, TacMultiply):
        return AsmMult()
    elif isinstance(node, TacBitAnd):
        return AsmBitAnd()
    elif isinstance(node, TacBitOr):
        return AsmBitOr()
    elif isinstance(node, TacBitXor):
        return AsmBitXor()
    elif isinstance(node, TacBitShiftLeft):
        return AsmBitShiftLeft()
    elif isinstance(node, TacBitShiftRight):
        return AsmBitShiftRight()
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef AsmUnaryOp generate_unary_op(TacUnaryOp node):
    # unary_operator = Not | Neg
    if isinstance(node, TacComplement):
        return AsmNot()
    elif isinstance(node, TacNegate):
        return AsmNeg()
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef list[AsmInstruction] instructions = []
cdef list[str] arg_registers = ["Di", "Si", "Dx", "Cx", "R8", "R9"]


cdef void generate_reg_arg_fun_call_instructions(TacValue node, int arg):
    cdef AsmOperand src = generate_operand(node)
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get(arg_registers[arg]))
    instructions.append(AsmMov(src, dst))


cdef void generate_stack_arg_fun_call_instructions(TacValue node, int arg):
    cdef AsmOperand src = generate_operand(node)
    if isinstance(node, (AsmRegister, AsmImm)):
        instructions.append(AsmPush(src))
        return
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Ax'))
    instructions.append(AsmMov(src, dst))
    instructions.append(AsmPush(dst))


cdef void generate_fun_call_instructions(TacFunCall node):
    cdef int stack_padding = 0
    if len(node.args) % 2 == 1:
        stack_padding = 8
        instructions.append(AsmAllocStack(TInt(stack_padding)))

    cdef int i
    for i in range(len(node.args)):
        if i < 6:
            generate_reg_arg_fun_call_instructions(node.args[i], i)
        else:
            stack_padding += 8
            i = len(node.args) - i + 5
            generate_stack_arg_fun_call_instructions(node.args[i], i)

    cdef TIdentifier name = generate_identifier(node.name)
    instructions.append(AsmCall(name))

    if stack_padding:
        instructions.append(AsmDeallocateStack(TInt(stack_padding)))

    cdef AsmOperand src = generate_register(REGISTER_KIND.get('Ax'))
    cdef AsmOperand dst = generate_operand(node.dst)
    instructions.append(AsmMov(src, dst))


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
    if isinstance(node, TacFunCall):
        generate_fun_call_instructions(node)
    elif isinstance(node, TacLabel):
        generate_label_instructions(node)
    elif isinstance(node, TacJump):
        generate_jump_instructions(node)
    elif isinstance(node, TacReturn):
        generate_return_instructions(node)
    elif isinstance(node, TacCopy):
        generate_copy_instructions(node)
    elif isinstance(node, TacJumpIfZero):
        generate_jump_if_zero_instructions(node)
    elif isinstance(node, TacJumpIfNotZero):
        generate_jump_if_not_zero_instructions(node)
    elif isinstance(node, TacUnary):
        if isinstance(node.unary_op, TacNot):
            generate_unary_operator_conditional_instructions(node)
        elif isinstance(node.unary_op, (TacComplement, TacNegate)):
            generate_unary_operator_arithmetic_instructions(node)
        else:

            raise RuntimeError(
                "An error occurred in assembly generation, not all nodes were visited")

    elif isinstance(node, TacBinary):
        if isinstance(node.binary_op, (TacEqual, TacNotEqual, TacLessThan, TacLessOrEqual, TacGreaterThan,
                                       TacGreaterOrEqual)):
            generate_binary_operator_conditional_instructions(node)
        elif isinstance(node.binary_op, (TacAdd, TacSubtract, TacMultiply, TacBitAnd, TacBitOr, TacBitXor,
                                         TacBitShiftLeft, TacBitShiftRight)):
            generate_binary_operator_arithmetic_instructions(node)
        elif isinstance(node.binary_op, TacDivide):
            generate_binary_operator_arithmetic_divide_instructions(node)
        elif isinstance(node.binary_op, TacRemainder):
            generate_binary_operator_arithmetic_remainder_instructions(node)
        else:

            raise RuntimeError(
                "An error occurred in assembly generation, not all nodes were visited")

    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef void generate_list_instructions(list[TacInstruction] list_node):
    # instruction = Mov(operand src, operand dst) | Unary(unary_operator, operand) | Cmp(operand, operand)
    #             | Idiv(operand) | Cdq | Jmp(identifier) | JmpCC(cond_code, identifier)
    #             | SetCC(cond_code, operand) | Label(identifier) | AllocateStack(int) | Ret

    cdef int instruction
    for instruction in range(len(list_node)):
        generate_instructions(list_node[instruction])


cdef void generate_reg_param_function_instructions(TIdentifier node, int param):
    cdef AsmOperand src = generate_register(REGISTER_KIND.get(arg_registers[param]))
    cdef TIdentifier name = generate_identifier(node)
    cdef AsmOperand dst = AsmPseudo(name)
    instructions.append(AsmMov(src, dst))


cdef void generate_stack_param_function_instructions(TIdentifier node, int param):
    cdef AsmOperand src = AsmStack(TInt((param - 4) * 8))
    cdef TIdentifier name = generate_identifier(node)
    cdef AsmOperand dst = AsmPseudo(name)
    instructions.append(AsmMov(src, dst))


cdef AsmFunctionDef generate_function_function_def(TacFunction node):
    global instructions

    cdef TIdentifier name
    name = generate_identifier(node.name)

    cdef list[TacInstruction] body = []
    instructions = body
    cdef int param
    for param in range(len(node.params)):
        if param < 6:
            generate_reg_param_function_instructions(node.params[param], param)
        else:
            generate_stack_param_function_instructions(node.params[param], param)
    generate_list_instructions(node.body)
    return AsmFunction(name, body)


cdef AsmFunctionDef generate_function_def(TacFunctionDef node):
    # function_definition = Function(identifier name, instruction* instructions)
    if isinstance(node, TacFunction):
        return generate_function_function_def(node)
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef AsmProgram generate_program(TacProgram node):
    # program = Program(function_definition)
    cdef int function_def
    cdef list[AsmFunctionDef] function_defs = []
    for function_def in range(len(node.function_defs)):
        function_defs.append(generate_function_def(node.function_defs[function_def]))
    return AsmProgram(function_defs)


cdef AsmProgram assembly_generation(TacProgram tac_ast):

    cdef AsmProgram asm_ast = generate_program(tac_ast)

    if not asm_ast:
        raise RuntimeError(
            "An error occurred in assembly generation, ASM was not generated")

    # correct_stack(asm_ast)

    return asm_ast
