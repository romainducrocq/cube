from ccc.assembly_asm_ast cimport AST

cdef void code_emission(AST asm_ast, str filename)

cdef list[str] code_emission_print(AST asm_ast) #
