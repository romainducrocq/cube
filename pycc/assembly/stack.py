from typing import Dict, List
from copy import deepcopy

from pycc.util.__ast import *
from pycc.assembly.asm_ast import *
from pycc.assembly.register import REGISTER_KIND, RegisterManager

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

    def correct_instructions(self, node: AST) -> None:

        def prepend_alloc_stack(instructions: List[AsmInstruction]) -> None:

            if self.counter == -1:
                raise StackManagerError(
                    "An error occurred in stack management, stack was not allocated")

            value: TInt = TInt(-1 * self.counter)
            instructions.insert(0, AsmAllocStack(value))

        for child_node, _, _ in AST.iter_child_nodes(node):
            if isinstance(child_node, AsmFunction):
                prepend_alloc_stack(child_node.instructions)

                for e, instruction in enumerate(reversed(child_node.instructions)):
                    i = len(child_node.instructions) - e
                    # mov addr, addr
                    if isinstance(instruction, AsmMov) and \
                            isinstance(instruction.src, AsmStack) and isinstance(instruction.dst, AsmStack):
                        src: AsmOperand = deepcopy(instruction.src)
                        instruction.src = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.R10))
                        child_node.instructions.insert(i - 1, AsmMov(src, deepcopy(instruction.src)))
                    elif isinstance(instruction, AsmBinary):
                        # add | sub addr, addr
                        if isinstance(instruction.binary_op, (AsmAdd, AsmSub)) and \
                                isinstance(instruction.src2, AsmStack) and isinstance(instruction.dst, AsmStack):
                            src: AsmOperand = deepcopy(instruction.src2)
                            instruction.src2 = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.R10))
                            child_node.instructions.insert(i - 1, AsmMov(src, deepcopy(instruction.src2)))
                        # mul _ addr
                        elif isinstance(instruction.binary_op, AsmMult) and \
                                isinstance(instruction.dst, AsmStack):
                            src: AsmOperand = deepcopy(instruction.dst)
                            instruction.dst = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.R11))
                            child_node.instructions.insert(i - 2, AsmMov(src, deepcopy(instruction.dst)))
                            child_node.instructions.insert(i, AsmMov(deepcopy(instruction.dst), deepcopy(src)))
                    # idiv imm
                    elif isinstance(instruction, AsmIdiv) and \
                            isinstance(instruction.src2, AsmImm):
                        src: AsmOperand = deepcopy(instruction.src2)
                        instruction.src2 = AsmRegister(RegisterManager.generate_register(REGISTER_KIND.R10))
                        child_node.instructions.insert(i - 1, AsmMov(src, deepcopy(instruction.src2)))

            else:
                self.correct_instructions(child_node)

    def generate_stack(self, node: AST) -> None:

        self.replace_pseudo_registers(node)

        self.correct_instructions(node)
