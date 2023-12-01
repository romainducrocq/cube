from ccc.parser_c_ast cimport CExp, TIdentifier

cdef TIdentifier resolve_label_identifier(TIdentifier label)
cdef TIdentifier resolve_variable_identifier(TIdentifier variable)
cdef TIdentifier represent_label_identifier(str label)
cdef TIdentifier represent_variable_identifier(CExp node)
