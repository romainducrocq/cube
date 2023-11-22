from ccc.util_iota_enum cimport IotaEnum
from ccc.assembly_asm_ast cimport AsmReg

cdef IotaEnum REGISTER_KIND

cdef AsmReg generate_register(int register_kind)
