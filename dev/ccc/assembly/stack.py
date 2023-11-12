from typing import Dict, List
from copy import deepcopy

from ccc.util.__ast import *
from ccc.assembly.asm_ast import *
from ccc.assembly.register import REGISTER_KIND, RegisterManager

__all__ = [
    'StackManager'
]


class StackManagerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(StackManagerError, self).__init__(message)


class StackManager:

    offset: int = -4
    counter: int = -1
    pseudo_map: Dict[str, int] = {}

    def __init__(self):
        pass

    def replace_pseudo_registers(self, node: AST) -> None:

        if self.counter == -1:
            self.counter = 0

        for child_node, attr, e in AST.iter_child_nodes(node):
            if isinstance(child_node, AsmPseudo):
                if child_node.name.str_t not in self.pseudo_map:
                    self.counter += self.offset
                    self.pseudo_map[child_node.name.str_t] = self.counter

                value: TInt = TInt(self.pseudo_map[child_node.name.str_t])
                AST.set_child_node(node, attr, e, AsmStack(value))

            else:
                self.replace_pseudo_registers(child_node)

    def prepend_alloc_stack(self, instructions: List[AsmInstruction]) -> None:

        if self.counter == -1:
            raise StackManagerError(
                "An error occurred in stack management, stack was not allocated")

        value: TInt = TInt(-1 * self.counter)
        instructions.insert(0, AsmAllocStack(value))

    def correct_instructions(self, node: AST) -> None:

        for child_node, _, _ in AST.iter_child_nodes(node):
            if isinstance(child_node, AsmFunction):
                self.prepend_alloc_stack(child_node.instructions)

                size = len(child_node.instructions)
                for e, instruction in enumerate(reversed(child_node.instructions)):
                    i = size - e
                    # mov | cmp (addr, addr)
                    # $ movl addr1, addr2 ->
                    #     $ movl addr1, reg
                    #     $ movl reg  , addr2
                    if isinstance(instruction, (AsmMov, AsmCmp)) and \
                            isinstance(instruction.src, AsmStack) and isinstance(instruction.dst, AsmStack):
                        src_src: AsmOperand = deepcopy(instruction.src)
                        instruction.src = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.R10))
                        child_node.instructions.insert(i - 1, AsmMov(src_src, deepcopy(instruction.src)))
                    elif isinstance(instruction, AsmBinary):
                        # add | sub | and | or | xor | shl | shr (addr, addr)
                        # $ addl addr1, addr2 ->
                        #     $ movl addr1, reg
                        #     $ addl reg  , addr2
                        if isinstance(instruction.binary_op, (AsmAdd, AsmSub, AsmBitAnd, AsmBitOr, AsmBitXor,
                                                              AsmBitShiftLeft, AsmBitShiftRight)) and \
                                isinstance(instruction.src, AsmStack) and isinstance(instruction.dst, AsmStack):
                            src_src: AsmOperand = deepcopy(instruction.src)
                            if isinstance(instruction.binary_op, (AsmBitShiftLeft, AsmBitShiftRight)):
                                instruction.src = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.CX))
                            else:
                                instruction.src = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.R10))
                            child_node.instructions.insert(i - 1, AsmMov(src_src, deepcopy(instruction.src)))
                        # mul (_, addr)
                        # $ imull imm, addr ->
                        #     $ movl  addr, reg
                        #     $ imull imm , reg
                        #     $ movl  reg , addr
                        elif isinstance(instruction.binary_op, AsmMult) and \
                                isinstance(instruction.dst, AsmStack):
                            src_src: AsmOperand = deepcopy(instruction.dst)
                            instruction.dst = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.R11))
                            child_node.instructions.insert(i - 1, AsmMov(src_src, deepcopy(instruction.dst)))
                            child_node.instructions.insert(i + 1, AsmMov(deepcopy(instruction.dst), deepcopy(src_src)))
                    # idiv (imm)
                    # $ idivl imm ->
                    #     $ movl  imm, reg
                    #     $ idivl reg
                    elif isinstance(instruction, AsmIdiv) and \
                            isinstance(instruction.src, AsmImm):
                        src_src: AsmOperand = deepcopy(instruction.src)
                        instruction.src = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.R10))
                        child_node.instructions.insert(i - 1, AsmMov(src_src, deepcopy(instruction.src)))
                    # $ cmpl reg1, imm ->
                    #     $ movl imm , reg2
                    #     $ cmpl reg1, reg2
                    elif isinstance(instruction, AsmCmp) and \
                            isinstance(instruction.dst, AsmImm):
                        src_src: AsmOperand = deepcopy(instruction.dst)
                        instruction.dst = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.R11))
                        child_node.instructions.insert(i - 1, AsmMov(src_src, deepcopy(instruction.dst)))
            else:
                self.correct_instructions(child_node)

    def generate_stack(self, node: AST) -> None:

        self.replace_pseudo_registers(node)

        self.correct_instructions(node)
