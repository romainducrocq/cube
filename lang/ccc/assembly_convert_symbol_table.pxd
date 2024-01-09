from ccc.assembly_asm_ast cimport AsmTopLevel
from ccc.assembly_backend_symbol_table cimport AssemblyType

cdef list[AsmTopLevel] static_constant_top_levels

cdef AssemblyType convert_backend_assembly_type(str name_str)
cdef void convert_symbol_table()
