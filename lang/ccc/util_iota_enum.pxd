from ccc.util_ctypes cimport int32

cdef class IotaEnum:
    cdef int32 iota_counter
    cdef dict[str, int32] iota_enum

    cdef int32 get(self, str key)
    cdef dict[str, int32] iter(self)
