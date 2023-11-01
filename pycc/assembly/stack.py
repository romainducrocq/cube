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
                    if isinstance(instruction, AsmMov) and \
                       isinstance(instruction.src, AsmStack) and \
                       isinstance(instruction.dst, AsmStack):
                        mov_to: AsmMov = deepcopy(instruction)
                        register: AsmReg = RegisterManager.generate_register(
                            REGISTER_KIND.R10)
                        instruction.dst = AsmRegister(register)
                        mov_to.src = AsmRegister(deepcopy(register))
                        child_node.instructions.insert(
                            len(child_node.instructions) - e, mov_to)

            else:
                self.correct_instructions(child_node)

    def generate_stack(self, node: AST) -> None:

        self.replace_pseudo_registers(node)

        self.correct_instructions(node)
