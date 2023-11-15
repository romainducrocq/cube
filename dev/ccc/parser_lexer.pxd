from ccc.util_iota_enum cimport IotaEnum

cdef IotaEnum TOKEN_KIND

cdef class Token:
    cdef str token
    cdef int token_kind

cpdef list[Token] lexing(str filename)
