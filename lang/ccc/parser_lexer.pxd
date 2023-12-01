from ccc.util_iota_enum cimport IotaEnum

cdef IotaEnum TOKEN_KIND

cdef class Token:
    cdef public str token
    cdef public int token_kind

cdef list[Token] lexing(str filename)
