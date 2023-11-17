import os
import re
import graphlib


cdef str PYX_TARGET = "ccc"
cdef str DIR_TARGET = f"{os.path.dirname(os.path.dirname(os.path.dirname(os.getcwd())))}/{PYX_TARGET}/"
cdef list[str] PYX_FILES = [f[:-4] for f in os.listdir(DIR_TARGET) if f.endswith(".pyx")]
cdef list[str] SORT_INCLUDES = []

cdef int PYX_ID = 0
cdef list[str] PXD_VARIABLES = []
cdef dict[str, list[str]] PXD_CLASSES = {}
cdef dict[str, object] PXD_PUBLIC_SYMBOLS = {}
cdef dict[str, object] PYX_PRIVATE_SYMBOLS = {}
cdef tuple[str, ...] SYMBOL_SKIP = ("main_c",)

cdef object RGX_SANITIZE = re.compile(r"[^\s*]\s{2,}|\n|\r|\t|\f|\v")
cdef object RGX_IS_LOCAL_CIMPORT = re.compile(r"^from {0}.*cimport\b.*$".format(PYX_TARGET))
cdef object RGX_IS_CLASS = re.compile(r"^(^cdef |^)class .*:$")
cdef object RGX_IS_FUNC_PXD = re.compile(r"^(^cdef |^cpdef |^def ).*\(.*\)\s*$")
cdef object RGX_IS_FUNC_PYX = re.compile(r"^(^cdef |^cpdef |^def ).*\(.*\)\s*:$")
cdef object RGX_IS_GLOB_VAR = re.compile(r"^cdef .*[^:$]$")
cdef object RGX_IS_CLASS_VAR = re.compile(r"^\s{4}cdef .*[^:$]$")
cdef object RGX_IS_PY_MAIN = re.compile(r"^cpdef.*main.py.*\(.*\)\s*:$")

cdef str FILE_BUFFER = ""
cdef object OUTPUT_FILE
cdef str OUTPUT_DIR = f"../../{PYX_TARGET}/"


""" file open """


from libc.stdio cimport *
cdef extern from "stdio.h":
    FILE *fopen(const char *, const char *)
    int fclose(FILE *)
    ssize_t getline(char **, size_t *, FILE *)


class FileError(RuntimeError):
    def __init__(self, message: str) -> None:
        self.message = message
        super(FileError, self).__init__(message)


cdef FILE *cfile = NULL


cdef void file_open_read(str filename):
    file_open(filename, "rb")


cdef void file_open(str filename, str mode):
    global cfile
    cfile = NULL

    cdef bytes b_filename = filename.encode("UTF-8")
    cdef char *c_filename = b_filename

    cfile = fopen(c_filename, mode.encode("UTF-8"))
    if cfile == NULL:

        raise FileError(
            f"File {filename} does not exist")


cdef tuple[bint, str] get_line():

    cdef size_t l = 0
    cdef char *cline = NULL
    cdef ssize_t read = getline(&cline, &l, cfile)

    if read == -1:
        return True, ''

    return False, str(cline.decode("UTF-8"))


cdef void file_close():

    fclose(cfile)


cdef str sanitize_line(str line):
    line = line.split("#")[0]
    return re.sub(RGX_SANITIZE, "", line)


"""  sort dependencies """


cdef void sort_includes():
    global SORT_INCLUDES
    SORT_INCLUDES = []

    cdef dict[str, set[str]] pxd_includes = {}

    cdef str pyx_file
    cdef str filename

    cdef bint eof
    cdef str line
    for pyx_file in PYX_FILES:
        pxd_includes[pyx_file] = set()

        filename = f"{DIR_TARGET}{pyx_file}.pyx"
        file_open_read(filename)

        while True:
            eof, line = get_line()
            if eof:
                break

            line = sanitize_line(line)
            if re.match(RGX_IS_LOCAL_CIMPORT, line):
                line = line.split(".")[1].split(" ")[0]
                pxd_includes[pyx_file].add(line)

        file_close()

    SORT_INCLUDES = list(graphlib.TopologicalSorter(pxd_includes).static_order())


"""  extract header  """


cdef str get_class_symbol(str line):
    return line.split(":")[0].lstrip(" ").\
                split("(")[0].lstrip(" ").split(" ")[-1]


cdef str get_function_symbol(str line):
    return line.split("(")[0].lstrip(" ").split(" ")[-1]


cdef str get_variable_symbol(str line):
    if "=" in line:
        return line.split("=")[0].lstrip(" ").\
               replace("*", "").\
               replace("&", "").\
               lstrip(" ").split(" ")[-2]
    return line.replace("*", "").\
           replace("&", "").\
           lstrip(" ").split(" ")[-1]


cdef str get_unique_id(str pyx_file, str symbol):
    return f"{pyx_file}{PYX_ID}_{symbol}"


cdef void extract_header(str pxd_file):
    global PYX_FILES
    global PXD_PUBLIC_SYMBOLS
    global PXD_VARIABLES
    global PXD_CLASSES
    PXD_VARIABLES = []
    PXD_CLASSES = {}

    cdef str filename = f"{DIR_TARGET}{pxd_file}.pxd"
    file_open_read(filename)

    cdef bint eof
    cdef str line
    cdef str clss
    cdef str symbol
    while True:
        eof, line = get_line()
        if eof:
            break

        line = sanitize_line(line)
        if re.match(RGX_IS_CLASS, line):
            clss = get_class_symbol(line)
            PXD_CLASSES[clss] = []
            PXD_PUBLIC_SYMBOLS[get_unique_id(pxd_file, clss)] = re.compile(r"\b{0}\b".format(clss))
        elif re.match(RGX_IS_FUNC_PXD, line):
            symbol = get_function_symbol(line)
            if symbol in SYMBOL_SKIP:
                continue
            PXD_PUBLIC_SYMBOLS[get_unique_id(pxd_file, symbol)] = re.compile(r"\b{0}\b".format(symbol))
        elif re.match(RGX_IS_GLOB_VAR, line):
            symbol = get_variable_symbol(line)
            PXD_PUBLIC_SYMBOLS[get_unique_id(pxd_file, symbol)] = re.compile(r"\b{0}\b".format(symbol))
            PXD_VARIABLES.append(line)
        elif re.match(RGX_IS_CLASS_VAR, line):
            PXD_CLASSES[clss].append(line)

    file_close()


"""  process source  """


cdef void append_file_buffer(str line):
    global FILE_BUFFER
    FILE_BUFFER += line + "\n"


cdef void process_source(str pyx_file):
    global PYX_PRIVATE_SYMBOLS
    global FILE_BUFFER
    PYX_PRIVATE_SYMBOLS = {}
    FILE_BUFFER = ""

    cdef str filename = f"{DIR_TARGET}{pyx_file}.pyx"
    file_open_read(filename)

    append_file_buffer("")
    cdef str line
    for line in PXD_VARIABLES:
        append_file_buffer(line)
    append_file_buffer("")

    cdef bint eof
    cdef str symbol
    cdef str unique_id
    while True:
        eof, line = get_line()
        if eof:
            break

        line = sanitize_line(line)
        if re.match(RGX_IS_LOCAL_CIMPORT, line):
            continue
        if re.match(RGX_IS_PY_MAIN, line):
            break

        append_file_buffer(line)
        if re.match(RGX_IS_CLASS, line):
            symbol = get_class_symbol(line)
            unique_id = get_unique_id(pyx_file, symbol)
            if not unique_id in PXD_PUBLIC_SYMBOLS:
                PYX_PRIVATE_SYMBOLS[unique_id] = re.compile(r"\b{0}\b".format(symbol))
            if symbol in PXD_CLASSES:
                for line in PXD_CLASSES[symbol]:
                    append_file_buffer(line)
                append_file_buffer("")
                append_file_buffer("")
        elif re.match(RGX_IS_FUNC_PYX, line):
            symbol = get_function_symbol(line)
            if symbol in SYMBOL_SKIP:
                continue
            unique_id = get_unique_id(pyx_file, symbol)
            if not unique_id in PXD_PUBLIC_SYMBOLS:
                PYX_PRIVATE_SYMBOLS[unique_id] = re.compile(r"\b{0}\b".format(symbol))
        elif re.match(RGX_IS_GLOB_VAR, line):
            symbol = get_variable_symbol(line)
            unique_id = get_unique_id(pyx_file, symbol)
            if not unique_id in PXD_PUBLIC_SYMBOLS:
                PYX_PRIVATE_SYMBOLS[unique_id] = re.compile(r"\b{0}\b".format(symbol))

    file_close()

    for unique_id in PXD_PUBLIC_SYMBOLS:
        FILE_BUFFER = re.sub(PXD_PUBLIC_SYMBOLS[unique_id], unique_id, FILE_BUFFER)

    for unique_id in PYX_PRIVATE_SYMBOLS:
        FILE_BUFFER = re.sub(PYX_PRIVATE_SYMBOLS[unique_id], unique_id, FILE_BUFFER)

    OUTPUT_FILE.write(FILE_BUFFER)


"""  main """


cdef void _main(list[str] args):
    global PYX_FILES
    global PYX_ID
    global OUTPUT_FILE
    OUTPUT_FILE = open(f"{OUTPUT_DIR}{PYX_TARGET}.pyx", "w")

    sort_includes()

    cdef str pyx_file
    for PYX_ID, pyx_file in enumerate(SORT_INCLUDES):

        extract_header(pyx_file)
        process_source(pyx_file)

    OUTPUT_FILE.close()


cdef public main_c(int argc, char **argv):
    cdef int i
    cdef list[str] args = []
    for i in range(argc):
        args.append(str(argv[i].decode("UTF-8")))

    _main(args)
