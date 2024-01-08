from ccc.assembly_asm_ast cimport AsmRegister, AsmReg
from ccc.assembly_asm_ast cimport AsmAx, AsmCx, AsmDx, AsmDi, AsmSi, AsmR8, AsmR9, AsmR10, AsmR11, AsmSp, AsmXMM0
from ccc.assembly_asm_ast cimport AsmXMM1, AsmXMM2, AsmXMM3, AsmXMM4, AsmXMM5, AsmXMM6, AsmXMM7, AsmXMM14, AsmXMM15

from ccc.util_ctypes cimport int32
from ccc.util_iota_enum cimport IotaEnum


REGISTER_KIND = IotaEnum((
    "Ax",
    "Cx",
    "Dx",
    "Di",
    "Si",
    "R8",
    "R9",
    "R10",
    "R11",
    "Sp",
    "Xmm0",
    "Xmm1",
    "Xmm2",
    "Xmm3",
    "Xmm4",
    "Xmm5",
    "Xmm6",
    "Xmm7",
    "Xmm14",
    "Xmm15"
))


cdef AsmRegister generate_register(int32 register_kind):
    # reg = AX | CX | DX | DI | SI | R8 | R9 | R10 | R11 | SP | XMM0 | XMM1 | XMM2 | XMM3 | XMM4 | XMM5 | XMM6 | XMM7
    #     | XMM14 | XMM15
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
    elif register_kind == REGISTER_KIND.get('Sp'):
        reg = AsmSp()
    elif register_kind == REGISTER_KIND.get('Xmm0'):
        reg = AsmXMM0()
    elif register_kind == REGISTER_KIND.get('Xmm1'):
        reg = AsmXMM1()
    elif register_kind == REGISTER_KIND.get('Xmm2'):
        reg = AsmXMM2()
    elif register_kind == REGISTER_KIND.get('Xmm3'):
        reg = AsmXMM3()
    elif register_kind == REGISTER_KIND.get('Xmm4'):
        reg = AsmXMM4()
    elif register_kind == REGISTER_KIND.get('Xmm5'):
        reg = AsmXMM5()
    elif register_kind == REGISTER_KIND.get('Xmm6'):
        reg = AsmXMM6()
    elif register_kind == REGISTER_KIND.get('Xmm7'):
        reg = AsmXMM7()
    elif register_kind == REGISTER_KIND.get('Xmm14'):
        reg = AsmXMM14()
    elif register_kind == REGISTER_KIND.get('Xmm15'):
        reg = AsmXMM15()
    else:

        raise RuntimeError(
            f"An error occurred in register management, unmanaged register [{register_kind}]")

    return AsmRegister(reg)
