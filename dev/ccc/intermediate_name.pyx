from ccc.parser_c_ast cimport (TIdentifier, CExp,
                               CVar, CConstant, CUnary, CBinary)


class NameManagerError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(NameManagerError, self).__init__(message)


cdef int label_counter = 0
cdef int variable_counter = 0


cdef TIdentifier resolve_variable_identifier(TIdentifier variable):
    global variable_counter

    variable_counter += 1
    cdef str name = f"{variable.str_t}.{variable_counter - 1}"

    return TIdentifier(name)


cdef TIdentifier represent_label_identifier(str label):
    global label_counter

    label_counter += 1
    cdef str name = f"{label}.{label_counter - 1}"

    return TIdentifier(name)


cdef TIdentifier represent_variable_identifier(CExp node):
    global variable_counter

    cdef str variable
    if isinstance(node, CVar):
        variable = "var"
    elif isinstance(node, CConstant):
        variable = "constant"
    elif isinstance(node, CUnary):
        variable = "unary"
    elif isinstance(node, CBinary):
        variable = "binary"
    else:

        raise NameManagerError(
            f"An error occurred in name management, unmanaged type {type(node)}")

    variable_counter += 1
    cdef str name = f"{variable}.{variable_counter - 1}"

    return TIdentifier(name)
