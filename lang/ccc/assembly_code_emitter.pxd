from ccc.assembly_asm_ast cimport AST

#
cdef list[str] code_emission_print(AST asm_ast) #

cdef void code_emission(AST asm_ast, str filename)
