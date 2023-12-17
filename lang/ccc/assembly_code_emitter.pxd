from ccc.assembly_asm_ast cimport AsmProgram

cdef list[str] code_emission_print(AsmProgram asm_ast) #
cdef void code_emission(AsmProgram asm_ast, str filename)
