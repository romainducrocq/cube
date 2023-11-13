cdef class IotaEnum:
    cdef int iota_counter
    cdef dict[unicode, int] iota_enum

    cpdef int get(self, unicode key)
