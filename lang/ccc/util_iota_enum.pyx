cdef class IotaEnum:

    def __init__(self, tuple[str, ...] names):
        self.iota_counter = 0
        self.iota_enum = {}

        cdef int name
        for name in range(len(names)):
            self.iota_enum[names[name]] = self.iota_counter
            self.iota_counter += 1

    cdef int get(self, str key):
        return self.iota_enum[key]

    cdef dict[str, int] iter(self):
        return self.iota_enum
