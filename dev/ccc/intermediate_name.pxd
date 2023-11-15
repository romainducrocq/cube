from ccc.parser_c_ast cimport CExp, TIdentifier

cpdef TIdentifier resolve_variable_identifier(TIdentifier variable)
cpdef TIdentifier represent_label_identifier(str label)
cpdef TIdentifier represent_variable_identifier(CExp node)
