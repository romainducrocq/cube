from ccc.util_ctypes cimport uint32

cdef class IotaEnum:
    cdef int iota_counter
    cdef dict[str, uint32] iota_enum

    cdef uint32 get(self, str key)
    cdef dict[str, uint32] iter(self)
