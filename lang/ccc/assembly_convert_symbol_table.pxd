from ccc.assembly_backend_symbol_table cimport AssemblyType
from ccc.assembly_asm_ast cimport AsmProgram

cdef AssemblyType convert_backend_assembly_type(str name_str)
cdef void convert_symbol_table(AsmProgram asm_ast)
