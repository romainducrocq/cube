from ccc.util_ast cimport AST, TIdentifier

cpdef TIdentifier resolve_variable_identifier(TIdentifier variable)
cpdef TIdentifier represent_label_identifier(str label)
cpdef TIdentifier represent_variable_identifier(AST node)
