from ccc.parser_c_ast cimport CProgram
from ccc.intermediate_tac_ast cimport TacProgram

cdef TacProgram three_address_code_representation(CProgram c_ast)
