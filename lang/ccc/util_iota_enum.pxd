cdef class IotaEnum:
    cdef int iota_counter
    cdef dict[str, int] iota_enum

    cdef int get(self, str key)
    cdef dict[str, int] iter(self)
