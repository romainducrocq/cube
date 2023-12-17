from ccc.util_ctypes cimport int32
from ccc.util_iota_enum cimport IotaEnum
from ccc.assembly_asm_ast cimport AsmRegister

cdef IotaEnum REGISTER_KIND

cdef AsmRegister generate_register(int32 register_kind)
