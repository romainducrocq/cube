from typing import Dict

__all__ = [
    'IotaEnum'
]


class IotaEnum(dict):
    __getattr__ = dict.__getitem__
    __setattr__ = dict.__setitem__
    __delattr__ = dict.__delitem__

    def __init__(self, *names: str):
        iota_counter: int = 0

        iota_enum: Dict[str, int] = {}
        for name in names:
            iota_enum[name] = iota_counter
            iota_counter += 1

        super(IotaEnum, self).__init__(iota_enum)
