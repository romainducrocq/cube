from ccc.util_ctypes cimport int32
from ccc.util_iota_enum cimport IotaEnum
from ccc.assembly_asm_ast cimport AsmRegister, AsmReg, AsmAx, AsmCx, AsmDx, AsmDi, AsmSi, AsmR8, AsmR9, AsmR10, AsmR11


REGISTER_KIND = IotaEnum((
    "Ax",
    "Cx",
    "Dx",
    "Di",
    "Si",
    "R8",
    "R9",
    "R10",
    "R11"
))


cdef AsmRegister generate_register(int32 register_kind):
    # reg = AX | CX | DX | DI | SI | R8 | R9 | R10 | R11

    cdef AsmReg reg
    if register_kind == REGISTER_KIND.get('Ax'):
        reg = AsmAx()
    elif register_kind == REGISTER_KIND.get('Cx'):
        reg = AsmCx()
    elif register_kind == REGISTER_KIND.get('Dx'):
        reg = AsmDx()
    elif register_kind == REGISTER_KIND.get('Di'):
        reg = AsmDi()
    elif register_kind == REGISTER_KIND.get('Si'):
        reg = AsmSi()
    elif register_kind == REGISTER_KIND.get('R8'):
        reg = AsmR8()
    elif register_kind == REGISTER_KIND.get('R9'):
        reg = AsmR9()
    elif register_kind == REGISTER_KIND.get('R10'):
        reg = AsmR10()
    elif register_kind == REGISTER_KIND.get('R11'):
        reg = AsmR11()

    else:

        raise RuntimeError(
            f"An error occurred in register management, unmanaged register [{register_kind}]")

    return AsmRegister(reg)
