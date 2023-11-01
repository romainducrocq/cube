from typing import Dict

from pycc.assembly.asm_ast import *
from pycc.util.iota_enum import IotaEnum

__all__ = [
    'REGISTER_KIND',
    'RegisterManager'
]


class RegisterManagerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(RegisterManagerError, self).__init__(message)


REGISTER_KIND: IotaEnum = IotaEnum(
    "AX",
    "R10"
)

REGISTER_NODE: Dict[int, type(AsmReg)] = {
    REGISTER_KIND.AX: AsmAx,
    REGISTER_KIND.R10: AsmR10
}


class RegisterManager:

    def __init__(self):
        pass

    @staticmethod
    def generate_register(register_kind: int) -> AsmReg:

        try:
            return REGISTER_NODE[register_kind]()
        except KeyError:

            raise RegisterManagerError(
                f"An error occurred in register management, unmanaged register {REGISTER_NODE[register_kind]}")
