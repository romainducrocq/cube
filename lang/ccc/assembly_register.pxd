from ccc.util_ctypes cimport uint32
from ccc.util_iota_enum cimport IotaEnum
from ccc.assembly_asm_ast cimport AsmRegister

cdef IotaEnum REGISTER_KIND

cdef AsmRegister generate_register(uint32 register_kind)
