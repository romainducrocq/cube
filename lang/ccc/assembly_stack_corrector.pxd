from ccc.assembly_asm_ast cimport AsmProgram, AsmBinary
from ccc.util_ctypes cimport int32

cdef AsmBinary allocate_stack_bytes(int32 byte)
cdef AsmBinary deallocate_stack_bytes(int32 byte)
cdef void correct_stack(AsmProgram asm_ast)
