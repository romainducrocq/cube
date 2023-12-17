from ccc.util_ctypes cimport uint32
from ccc.util_iota_enum cimport IotaEnum

cdef IotaEnum TOKEN_KIND

cdef class Token:
    cdef public str token
    cdef public uint32 token_kind

cdef list[Token] lexing(str filename)
