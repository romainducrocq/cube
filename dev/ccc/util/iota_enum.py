__all__ = [
    'IotaEnum'
]


cdef class IotaEnum:
    cdef int iota_counter
    cdef dict[str, int] iota_enum

    def __init__(self, tuple[str] names):
        cdef str name
        self.iota_counter = 0
        self.iota_enum = {}
        for name in names:
            self.iota_enum[name] = self.iota_counter
            self.iota_counter += 1

    cpdef int get(self, str key):
        return self.iota_enum[key]
