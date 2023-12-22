from ccc.abc_builtin_ast cimport copy_identifier, copy_int, copy_long

from ccc.parser_c_ast cimport Int, Long, CConstInt, CConstLong
from ccc.intermediate_tac_ast cimport *

from ccc.assembly_asm_ast cimport *
from ccc.assembly_backend_symbol_table cimport AssemblyType, LongWord, QuadWord
from ccc.assembly_convert_symbol_table cimport convert_backend_assembly_type, convert_symbol_table
from ccc.assembly_register cimport REGISTER_KIND, generate_register
# from ccc.assembly_stack_corrector cimport correct_stack

from ccc.util_ctypes cimport int32


cdef TInt generate_alignment(Type node):
    if isinstance(node, Int):
        return TInt(4)
    elif isinstance(node, Long):
        return TInt(8)
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef AsmImmInt generate_int_imm_operand(CConstInt node):
    cdef TInt value = copy_int(node.value)
    return AsmImmInt(value)


cdef AsmImmLong generate_long_imm_operand(CConstLong node):
    cdef TLong value = copy_long(node.value)
    return AsmImmLong(value)


cdef AsmOperand generate_imm_operand(TacConstant node):
    if isinstance(node.constant, CConstInt):
        return generate_int_imm_operand(node.constant)
    elif isinstance(node.constant, CConstLong):
        return generate_long_imm_operand(node.constant)
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef AsmPseudo generate_pseudo_operand(TacVariable node):
    cdef TIdentifier identifier = copy_identifier(node.name)
    return AsmPseudo(identifier)


cdef AsmOperand generate_operand(TacValue node):
    # operand = ImmInt(int) | ImmLong(long) | Reg(reg) | Pseudo(identifier) | Stack(int) | Data(identifier)
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


cdef AssemblyType generate_constant_assembly_type(TacConstant node):
    if isinstance(node.constant, CConstInt):
        return LongWord()
    elif isinstance(node.constant, CConstLong):
        return QuadWord()
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef AssemblyType generate_variable_assembly_type(TacVariable node):
    return convert_backend_assembly_type(node.name.str_t)


cdef AssemblyType generate_assembly_type(TacValue node):
    if isinstance(node, TacConstant):
        return generate_constant_assembly_type(node)
    elif isinstance(node, TacVariable):
        return generate_variable_assembly_type(node)
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef void generate_allocate_stack_instructions(int32 byte):
    cdef AsmBinaryOp binary_op = AsmSub()
    cdef AssemblyType assembly_type = QuadWord()
    cdef AsmOperand src = AsmImmInt(TInt(byte))
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    instructions.append(AsmBinary(binary_op, assembly_type, src, dst))


cdef void generate_deallocate_stack_instructions(int32 byte):
    cdef AsmBinaryOp binary_op = AsmAdd()
    cdef AssemblyType assembly_type = QuadWord()
    cdef AsmOperand src = AsmImmInt(TInt(byte))
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Sp'))
    instructions.append(AsmBinary(binary_op, assembly_type, src, dst))


cdef list[AsmInstruction] instructions = []
cdef list[str] arg_registers = ["Di", "Si", "Dx", "Cx", "R8", "R9"]


cdef void generate_reg_arg_fun_call_instructions(TacValue node, Py_ssize_t arg):
    cdef AsmOperand src = generate_operand(node)
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get(arg_registers[arg]))
    cdef AssemblyType assembly_type = generate_assembly_type(node)
    instructions.append(AsmMov(assembly_type, src, dst))


cdef void generate_stack_arg_fun_call_instructions(TacValue node):
    cdef AsmOperand src = generate_operand(node)
    cdef AssemblyType assembly_type = generate_assembly_type(node)
    if isinstance(src, (AsmRegister, AsmImmInt, AsmImmLong)) or \
       isinstance(assembly_type, QuadWord):
        instructions.append(AsmPush(src))
        return
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Ax'))
    instructions.append(AsmMov(assembly_type, src, dst))
    instructions.append(AsmPush(dst))


cdef void generate_fun_call_instructions(TacFunCall node):
    cdef int32 stack_padding = 0
    if len(node.args) % 2 == 1:
        stack_padding = 8
        instructions.append(generate_allocate_stack_instructions(stack_padding))

    cdef Py_ssize_t i
    for i in range(len(node.args)):
        if i < 6:
            generate_reg_arg_fun_call_instructions(node.args[i], i)
        else:
            stack_padding += 8
            i = len(node.args) - i + 5
            generate_stack_arg_fun_call_instructions(node.args[i])

    cdef TIdentifier name = copy_identifier(node.name)
    instructions.append(AsmCall(name))

    if stack_padding:
        instructions.append(generate_deallocate_stack_instructions(stack_padding))

    cdef AsmOperand src = generate_register(REGISTER_KIND.get('Ax'))
    cdef AsmOperand dst = generate_operand(node.dst)
    cdef AssemblyType assembly_type_dst = generate_assembly_type(node.dst)
    instructions.append(AsmMov(assembly_type_dst, src, dst))


cdef void generate_sign_extend_instructions(TacSignExtend node):
    cdef AsmOperand src = generate_operand(node.src)
    cdef AsmOperand dst = generate_operand(node.dst)
    instructions.append(AsmMovSx(src, dst))


cdef void generate_truncate_instructions(TacTruncate node):
    cdef AsmOperand src = generate_operand(node.src)
    cdef AsmOperand dst = generate_operand(node.dst)
    cdef AssemblyType assembly_type_src = LongWord()
    instructions.append(AsmMov(assembly_type_src, src, dst))


cdef void generate_label_instructions(TacLabel node):
    cdef TIdentifier name = copy_identifier(node.name)
    instructions.append(AsmLabel(name))


cdef void generate_jump_instructions(TacJump node):
    cdef TIdentifier target = copy_identifier(node.target)
    instructions.append(AsmJmp(target))


cdef void generate_return_instructions(TacReturn node):
    cdef AsmOperand src = generate_operand(node.val)
    cdef AsmOperand dst = generate_register(REGISTER_KIND.get('Ax'))
    cdef AssemblyType assembly_type_val = generate_assembly_type(node.val)
    instructions.append(AsmMov(assembly_type_val, src, dst))
    instructions.append(AsmRet())


cdef void generate_copy_instructions(TacCopy node):
    cdef AsmOperand src = generate_operand(node.src)
    cdef AsmOperand dst = generate_operand(node.dst)
    cdef AssemblyType assembly_type_src = generate_assembly_type(node.src)
    instructions.append(AsmMov(assembly_type_src, src, dst))


cdef void generate_jump_if_zero_instructions(TacJumpIfZero node):
    cdef AsmOperand imm_zero = AsmImmInt(TInt(0))
    cdef AsmCondCode cond_code = generate_condition_code(TacEqual())
    cdef TIdentifier target = copy_identifier(node.target)
    cdef AsmOperand condition = generate_operand(node.condition)
    cdef AssemblyType assembly_type_cond = generate_assembly_type(node.condition)
    instructions.append(AsmCmp(assembly_type_cond, imm_zero, condition))
    instructions.append(AsmJmpCC(cond_code, target))


cdef void generate_jump_if_not_zero_instructions(TacJumpIfNotZero node):
    cdef AsmOperand imm_zero = AsmImmInt(TInt(0))
    cdef AsmCondCode cond_code = generate_condition_code(TacNotEqual())
    cdef TIdentifier target = copy_identifier(node.target)
    cdef AsmOperand condition = generate_operand(node.condition)
    cdef AssemblyType assembly_type_cond = generate_assembly_type(node.condition)
    instructions.append(AsmCmp(assembly_type_cond, imm_zero, condition))
    instructions.append(AsmJmpCC(cond_code, target))


cdef void generate_unary_operator_conditional_instructions(TacUnary node):
    cdef imm_zero = AsmImmInt(TInt(0))
    cdef cond_code = generate_condition_code(TacEqual())
    cdef src = generate_operand(node.src)
    cdef cmp_dst = generate_operand(node.dst)
    cdef AssemblyType assembly_type_src = generate_assembly_type(node.src)
    cdef AssemblyType assembly_type_dst = generate_assembly_type(node.dst)
    instructions.append(AsmCmp(assembly_type_src, imm_zero, src))
    instructions.append(AsmMov(assembly_type_dst, imm_zero, cmp_dst))
    instructions.append(AsmSetCC(cond_code, cmp_dst))


cdef void generate_unary_operator_arithmetic_instructions(TacUnary node):
    cdef AsmUnaryOp unary_op = generate_unary_op(node.unary_op)
    cdef AsmOperand src = generate_operand(node.src)
    cdef AsmOperand src_dst = generate_operand(node.dst)
    cdef AssemblyType assembly_type_src = generate_assembly_type(node.src)
    instructions.append(AsmMov(assembly_type_src, src, src_dst))
    instructions.append(AsmUnary(unary_op, assembly_type_src, src_dst))


cdef void generate_binary_operator_conditional_instructions(TacBinary node):
    cdef imm_zero = AsmImmInt(TInt(0))
    cdef cond_code = generate_condition_code(node.binary_op)
    cdef src1 = generate_operand(node.src1)
    cdef src2 = generate_operand(node.src2)
    cdef cmp_dst = generate_operand(node.dst)
    cdef AssemblyType assembly_type_src1 = generate_assembly_type(node.src1)
    cdef AssemblyType assembly_type_dst = generate_assembly_type(node.dst)
    instructions.append(AsmCmp(assembly_type_src1, src2, src1))
    instructions.append(AsmMov(assembly_type_dst, imm_zero, cmp_dst))
    instructions.append(AsmSetCC(cond_code, cmp_dst))


cdef void generate_binary_operator_arithmetic_instructions(TacBinary node):
    cdef AsmBinaryOp binary_op = generate_binary_op(node.binary_op)
    cdef AsmOperand src1 = generate_operand(node.src1)
    cdef AsmOperand src2 = generate_operand(node.src2)
    cdef AsmOperand src1_dst = generate_operand(node.dst)
    cdef AssemblyType assembly_type_src1 = generate_assembly_type(node.src1)
    instructions.append(AsmMov(assembly_type_src1, src1, src1_dst))
    instructions.append(AsmBinary(binary_op, assembly_type_src1, src2, src1_dst))


cdef void generate_binary_operator_arithmetic_divide_instructions(TacBinary node):
    cdef AsmOperand src1 = generate_operand(node.src1)
    cdef AsmOperand src2 = generate_operand(node.src2)
    cdef AsmOperand dst = generate_operand(node.dst)
    cdef AsmOperand src1_dst = generate_register(REGISTER_KIND.get('Ax'))
    cdef AsmOperand dst_src = generate_register(REGISTER_KIND.get('Ax'))
    cdef AssemblyType assembly_type_src1 = generate_assembly_type(node.src1)
    instructions.append(AsmMov(assembly_type_src1, src1, src1_dst))
    instructions.append(AsmCdq(assembly_type_src1))
    instructions.append(AsmIdiv(assembly_type_src1, src2))
    instructions.append(AsmMov(assembly_type_src1, dst_src, dst))


cdef void generate_binary_operator_arithmetic_remainder_instructions(TacBinary node):
    cdef AsmOperand src1 = generate_operand(node.src1)
    cdef AsmOperand src2 = generate_operand(node.src2)
    cdef AsmOperand dst = generate_operand(node.dst)
    cdef AsmOperand src1_dst = generate_register(REGISTER_KIND.get('Ax'))
    cdef AsmOperand dst_src = generate_register(REGISTER_KIND.get('Dx'))
    cdef AssemblyType assembly_type_src1 = generate_assembly_type(node.src1)
    instructions.append(AsmMov(assembly_type_src1, src1, src1_dst))
    instructions.append(AsmCdq(assembly_type_src1))
    instructions.append(AsmIdiv(assembly_type_src1, src2))
    instructions.append(AsmMov(assembly_type_src1, dst_src, dst))


cdef void generate_instructions(TacInstruction node):
    if isinstance(node, TacFunCall):
        generate_fun_call_instructions(node)
    elif isinstance(node, TacSignExtend):
        generate_sign_extend_instructions(node)
    elif isinstance(node, TacTruncate):
        generate_truncate_instructions(node)
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

    cdef Py_ssize_t instruction
    for instruction in range(len(list_node)):
        generate_instructions(list_node[instruction])


cdef void generate_reg_param_function_instructions(TIdentifier node, Py_ssize_t param):
    cdef AsmOperand src = generate_register(REGISTER_KIND.get(arg_registers[param]))
    cdef TIdentifier name = copy_identifier(node)
    cdef AsmOperand dst = AsmPseudo(name)
    cdef AssemblyType assembly_type_param = convert_backend_assembly_type(node.str_t)
    instructions.append(AsmMov(assembly_type_param, src, dst))


cdef void generate_stack_param_function_instructions(TIdentifier node, int32 param):
    cdef AsmOperand src = AsmStack(TInt((param - 4) * 8))
    cdef TIdentifier name = copy_identifier(node)
    cdef AsmOperand dst = AsmPseudo(name)
    cdef AssemblyType assembly_type_param = convert_backend_assembly_type(node.str_t)
    instructions.append(AsmMov(assembly_type_param, src, dst))


cdef AsmFunction generate_function_top_level(TacFunction node):
    global instructions

    cdef TIdentifier name = copy_identifier(node.name)
    cdef bint is_global = node.is_global

    cdef list[TacInstruction] body = []
    instructions = body
    cdef Py_ssize_t param
    for param in range(len(node.params)):
        if param < 6:
            generate_reg_param_function_instructions(node.params[param], param)
        else:
            generate_stack_param_function_instructions(node.params[param], param)
    generate_list_instructions(node.body)
    return AsmFunction(name, is_global, body)


cdef AsmStaticVariable generate_static_variable_top_level(TacStaticVariable node):
    cdef TIdentifier name = copy_identifier(node.name)
    cdef bint is_global = node.is_global
    cdef TInt alignment = generate_alignment(node.static_init_type)
    cdef StaticInit initial_value = node.initial_value
    return AsmStaticVariable(name, is_global, alignment, initial_value)


cdef AsmTopLevel generate_top_level(TacTopLevel node):
    # top_level = Function(identifier name, bool global, instruction* instructions)
    #           | StaticVariable(identifier, bool global, int init)
    if isinstance(node, TacFunction):
        return generate_function_top_level(node)
    elif isinstance(node, TacStaticVariable):
        return generate_static_variable_top_level(node)
    else:

        raise RuntimeError(
            "An error occurred in assembly generation, not all nodes were visited")


cdef AsmProgram generate_program(TacProgram node):
    # program = Program(function_definition)
    cdef Py_ssize_t top_level
    cdef list[AsmTopLevel] top_levels = []
    for top_level in range(len(node.top_levels)):
        top_levels.append(generate_top_level(node.top_levels[top_level]))
    return AsmProgram(top_levels)


cdef AsmProgram assembly_generation(TacProgram tac_ast):

    cdef AsmProgram asm_ast = generate_program(tac_ast)

    if not asm_ast:
        raise RuntimeError(
            "An error occurred in assembly generation, ASM was not generated")

    convert_symbol_table()

    # correct_stack(asm_ast)

    return asm_ast
