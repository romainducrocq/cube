cdef class IotaEnum:
    cdef int iota_counter
    cdef dict[str, int] iota_enum

    cpdef int get(self, str key)
    cpdef dict[str, int] iter(self)
