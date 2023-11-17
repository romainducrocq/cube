from copy import deepcopy

from ccc.parser_c_ast cimport *
from ccc.intermediate_tac_ast cimport *
from ccc.intermediate_name cimport represent_label_identifier, represent_variable_identifier


class ThreeAddressCodeGeneratorError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(ThreeAddressCodeGeneratorError, self).__init__(message)


cdef TIdentifier represent_identifier(TIdentifier node):
    """ <identifier> = Built-in identifier type """
    return TIdentifier(deepcopy(node.str_t))


cdef TInt represent_int(TInt node):
    """ <int> = Built-in int type """
    return TInt(deepcopy(node.int_t))

cdef TacBinaryOp represent_binary_op(CBinaryOp node):
    """ binary_operator = Add | Subtract | Multiply | Divide | Remainder | BitAnd | BitOr | BitXor
                        | BitShiftLeft | BitShiftRight | Equal | NotEqual | LessThan | LessOrEqual
                        | GreaterThan | GreaterOrEqual """
    if isinstance(node, CAdd):
        return TacAdd()
    if isinstance(node, CSubtract):
        return TacSubtract()
    if isinstance(node, CMultiply):
        return TacMultiply()
    if isinstance(node, CDivide):
        return TacDivide()
    if isinstance(node, CRemainder):
        return TacRemainder()
    if isinstance(node, CBitAnd):
        return TacBitAnd()
    if isinstance(node, CBitOr):
        return TacBitOr()
    if isinstance(node, CBitXor):
        return TacBitXor()
    if isinstance(node, CBitShiftLeft):
        return TacBitShiftLeft()
    if isinstance(node, CBitShiftRight):
        return TacBitShiftRight()
    if isinstance(node, CEqual):
        return TacEqual()
    if isinstance(node, CNotEqual):
        return TacNotEqual()
    if isinstance(node, CLessThan):
        return TacLessThan()
    if isinstance(node, CLessOrEqual):
        return TacLessOrEqual()
    if isinstance(node, CGreaterThan):
        return TacGreaterThan()
    if isinstance(node, CGreaterOrEqual):
        return TacGreaterOrEqual()

    raise ThreeAddressCodeGeneratorError(
        "An error occurred in three address code representation, not all nodes were visited")


cdef TacUnaryOp represent_unary_op(CUnaryOp node):
    """ unary_operator = Complement | Negate | Not """
    if isinstance(node, CComplement):
        return TacComplement()
    if isinstance(node, CNegate):
        return TacNegate()
    if isinstance(node, CNot):
        return TacNot()

    raise ThreeAddressCodeGeneratorError(
        "An error occurred in three address code representation, not all nodes were visited")


cdef TacValue represent_value(CExp node, bint outer = True):
    """ val = Constant(int) | Var(identifier) """
    cdef TInt value
    cdef TIdentifier name
    if outer:
        if isinstance(node, CConstant):
            value = represent_int(node.value)
            return TacConstant(value)
        if isinstance(node, CVar):
            name = represent_identifier(node.name)
            return TacVariable(name)

        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, not all nodes were visited")

    name = represent_variable_identifier(node)
    return TacVariable(name)


cdef list[TacInstruction] instructions = []


cdef TacValue represent_exp_instructions(CExp node):
    cdef TacValue val
    if isinstance(node, (CVar, CConstant)):
        val = represent_value(node)
        return val
    cdef TacValue src
    cdef TacValue dst
    if isinstance(node, CAssignment):
        src = represent_exp_instructions(node.exp_right)
        dst = represent_exp_instructions(node.exp_left)
        instructions.append(TacCopy(src, dst))
        return dst
    cdef TacUnaryOp unary_op
    if isinstance(node, CUnary):
        src = represent_exp_instructions(node.exp)
        dst = represent_value(node.exp, outer=False)
        unary_op = represent_unary_op(node.unary_op)
        instructions.append(TacUnary(unary_op, src, dst))
        return dst
    cdef TacValue src2
    cdef TacBinaryOp binary_op
    if isinstance(node, CBinary) and \
            not isinstance(node.binary_op, (CAnd, COr)):
        src = represent_exp_instructions(node.exp_left)
        src2 = represent_exp_instructions(node.exp_right)
        dst = represent_value(node.exp_left, outer=False)
        binary_op = represent_binary_op(node.binary_op)
        instructions.append(TacBinary(binary_op, src, src2, dst))
        return dst
    if isinstance(node, CAssignmentCompound):
        src = represent_exp_instructions(node.exp_left)
        src2 = represent_exp_instructions(node.exp_right)
        val = represent_value(node.exp_left, outer=False)
        binary_op = represent_binary_op(node.binary_op)
        instructions.append(TacBinary(binary_op, src, src2, val))
        dst = represent_value(node.exp_left)
        instructions.append(TacCopy(val, dst))
        return dst
    cdef TacValue istrue
    cdef TacValue is_false
    cdef TIdentifier label_true
    cdef TIdentifier label_false
    if isinstance(node, CBinary):
        if isinstance(node.binary_op, CAnd):
            is_true = TacConstant(TInt(1))
            is_false = TacConstant(TInt(0))
            label_true = represent_label_identifier("and_true")
            label_false = represent_label_identifier("and_false")
            src = represent_exp_instructions(node.exp_left)
            instructions.append(TacJumpIfZero(src, label_false))
            src2 = represent_exp_instructions(node.exp_right)
            instructions.append(TacJumpIfZero(src2, label_false))
            dst = represent_value(node.exp_left, outer=False)
            instructions.append(TacCopy(is_true, dst))
            instructions.append(TacJump(label_true))
            instructions.append(TacLabel(label_false))
            instructions.append(TacCopy(is_false, dst))
            instructions.append(TacLabel(label_true))
            return dst
        if isinstance(node.binary_op, COr):
            is_true = TacConstant(TInt(1))
            is_false = TacConstant(TInt(0))
            label_true = represent_label_identifier("or_true")
            label_false = represent_label_identifier("or_false")
            src = represent_exp_instructions(node.exp_left)
            instructions.append(TacJumpIfNotZero(src, label_true))
            src2 = represent_exp_instructions(node.exp_right)
            instructions.append(TacJumpIfNotZero(src2, label_true))
            dst = represent_value(node.exp_left, outer=False)
            instructions.append(TacCopy(is_false, dst))
            instructions.append(TacJump(label_false))
            instructions.append(TacLabel(label_true))
            instructions.append(TacCopy(is_true, dst))
            instructions.append(TacLabel(label_false))
            return dst

    raise ThreeAddressCodeGeneratorError(
        "An error occurred in three address code representation, not all nodes were visited")


cdef void represent_statement_instructions(CStatement node):
    if isinstance(node, CNull):
        return
    if isinstance(node, CExpression):
        _ = represent_exp_instructions(node.exp)
        return
    cdef TacValue val
    if isinstance(node, CReturn):
        val = represent_exp_instructions(node.exp)
        instructions.append(TacReturn(val))
        return

    raise ThreeAddressCodeGeneratorError(
        "An error occurred in three address code representation, not all nodes were visited")


cdef void represent_declaration_instructions(CDeclaration node):
    cdef TacValue src
    cdef TacValue dst
    if isinstance(node, CDecl):
        if node.init:
            src = represent_exp_instructions(node.init)
            dst = represent_value(CVar(node.name))
            instructions.append(TacCopy(src, dst))
        return

    raise ThreeAddressCodeGeneratorError(
        "An error occurred in three address code representation, not all nodes were visited")


cdef void represent_list_instructions(list[CBlockItem] list_node):
    """ instruction = Return(val) | Unary(unary_operator, val src, val dst)
                | Binary(binary_operator, val src1, val src2, val dst) | Copy(val src, val dst)
                | Jump(identifier target) | JumpIfZero(val condition, identifier target)
                | JumpIfNotZero(val condition, identifier target) | Label(identifier name) """
    global instructions
    instructions = []

    cdef CBlockItem item_node
    for item_node in list_node:
        if isinstance(item_node, CS):
            represent_statement_instructions(item_node.statement)
        elif isinstance(item_node, CD):
            represent_declaration_instructions(item_node.declaration)
        else:

            raise ThreeAddressCodeGeneratorError(
                "An error occurred in three address code representation, not all nodes were visited")

    instructions.append(TacReturn(TacConstant(TInt(0))))


cdef TacFunctionDef represent_function_def(CFunctionDef node):
    """ function_definition = Function(identifier, instruction* body) """
    cdef TIdentifier name
    if isinstance(node, CFunction):
        name = represent_identifier(node.name)
        represent_list_instructions(node.body)
        return TacFunction(name, instructions)

    raise ThreeAddressCodeGeneratorError(
        "An error occurred in three address code representation, not all nodes were visited")


cdef TacProgram represent_program(AST node):
    """ AST = Program(function_definition) """
    cdef TacFunctionDef function_def
    if isinstance(node, CProgram):
        function_def = represent_function_def(node.function_def)
        return TacProgram(function_def)

    raise ThreeAddressCodeGeneratorError(
        "An error occurred in three address code representation, not all nodes were visited")


cdef AST three_address_code_representation(AST c_ast):

    cdef AST tac_ast = represent_program(c_ast)

    if not tac_ast:
        raise ThreeAddressCodeGeneratorError(
            "An error occurred in three address code representation, Asm was not generated")

    return tac_ast
