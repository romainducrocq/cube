""" UTILS """


""" debug """


DEBUG: bool = True


def debug(string: str = "", end="\n") -> None:
    if DEBUG:
        print(string, end=end)


""" iota """


iota_counter: int = 0


def iota(init: bool = False) -> int:
    global iota_counter
    if init:
        iota_counter = 0

    iota_counter += 1
    return iota_counter - 1


""" attribute dict """


class AttributeDict(dict):
    __getattr__ = dict.__getitem__
    __setattr__ = dict.__setitem__
    __delattr__ = dict.__delitem__
