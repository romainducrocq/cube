from ccc.util_iota_enum cimport IotaEnum
from ccc.assembly_asm_ast cimport AsmReg, AsmAx, AsmCx, AsmDx, AsmR10, AsmR11


REGISTER_KIND = IotaEnum((
    "Ax",
    "Cx",
    "Dx",
    "R10",
    "R11"
))


cdef AsmReg generate_register(int register_kind):
    # reg = AX | CX | DX | R10 | R11

    if register_kind == REGISTER_KIND.get('Ax'):
        return AsmAx()
    elif register_kind == REGISTER_KIND.get('Cx'):
        return AsmCx()
    elif register_kind == REGISTER_KIND.get('Dx'):
        return AsmDx()
    elif register_kind == REGISTER_KIND.get('R10'):
        return AsmR10()
    elif register_kind == REGISTER_KIND.get('R11'):
        return AsmR11()

    else:

        raise RuntimeError(
            f"An error occurred in register management, unmanaged register [{register_kind}]")
