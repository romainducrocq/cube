from ccc.util_ctypes cimport uint32

cdef class IotaEnum:

    def __init__(self, tuple[str, ...] names):
        self.iota_counter = 0
        self.iota_enum = {}

        cdef Py_ssize_t name
        for name in range(len(names)):
            self.iota_enum[names[name]] = self.iota_counter
            self.iota_counter += 1

    cdef uint32 get(self, str key):
        return self.iota_enum[key]

    cdef dict[str, uint32] iter(self):
        return self.iota_enum
