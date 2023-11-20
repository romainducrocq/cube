from os import path as os_path
from os import getcwd as os_getcwd
from os import listdir as os_listdir
from re import compile as re_compile
from re import match as re_match
from re import sub as re_sub
from graphlib import TopologicalSorter as graphlib_TopologicalSorter


cdef str PACKAGE_NAME="ccc"
cdef str OUTPUT_DIR = f"../../{PACKAGE_NAME}/"
cdef str DIR_TARGET = f"{os_path.dirname(os_path.dirname(os_path.dirname(os_getcwd())))}/{PACKAGE_NAME}/"
cdef list[str] PYX_FILES = [f[:-4] for f in os_listdir(DIR_TARGET) if f.endswith(".pyx")]
cdef list[str] SORT_INCLUDES = []
cdef tuple[str, ...] SYMBOL_SKIP = ("main_c",)

cdef object RGX_SANITIZE = re_compile(r"[^\s*]\s{2,}|\n|\r|\t|\f|\v")
cdef object RGX_IS_LOCAL_CIMPORT = re_compile(r"^from {0}.*cimport\b.*$".format(PACKAGE_NAME))
cdef object RGX_IS_CLASS = re_compile(r"^(^cdef |^)class .*:$")
cdef object RGX_IS_FUNC_PXD = re_compile(r"^(^cdef |^cpdef |^def ).*\(.*\)\s*$")
cdef object RGX_IS_FUNC_PYX = re_compile(r"^(^cdef |^cpdef |^def ).*\(.*\)\s*:$")
cdef object RGX_IS_GLOB_VAR = re_compile(r"^cdef .*[^:$]$")
cdef object RGX_IS_CLASS_VAR = re_compile(r"^\s{4}cdef .*[^:$]$")
cdef object RGX_IS_PY_MAIN = re_compile(r"^cpdef.*main.py.*\(.*\)\s*:$")

cdef int pyx_id = 0
cdef list[str] pxd_variables = []
cdef dict[str, list[str]] pxd_classes = {}
cdef dict[str, object] pxd_public_symbols = {}
cdef dict[str, object] pyx_private_symbols = {}
cdef str file_buf = ""


""" file open """


from libc.stdio cimport *
cdef extern from "stdio.h":
    FILE *fopen(const char *, const char *)
    int fclose(FILE *)
    ssize_t getline(char **, size_t *, FILE *)


cdef FILE *c_file_in = NULL
cdef object file_out
cdef str stream_buf = ""


cdef void file_open_read(str filename):
    global c_file_in
    c_file_in = NULL

    cdef bytes b_filename = filename.encode("UTF-8")
    cdef char *c_filename = b_filename

    c_file_in = fopen(c_filename, "rb")
    if c_file_in == NULL:

        raise RuntimeError(
            f"File {filename} does not exist")


cdef void file_open_write(str filename):
    global file_out
    global stream_buf
    file_out = open(filename, "w", encoding="utf-8")
    stream_buf = ""


cdef tuple[bint, str] read_line():

    cdef size_t l = 0
    cdef char *cline = NULL
    cdef ssize_t read = getline(&cline, &l, c_file_in)

    if read == -1:
        return True, ''

    return False, str(cline.decode("UTF-8"))


cdef void write_file(str stream, int chunk_size = 4096):
    global stream_buf

    stream_buf += stream
    while len(stream_buf) >= chunk_size:
        file_out.write(stream_buf[:chunk_size])
        stream_buf = stream_buf[chunk_size:]


cdef void file_close_read():

    fclose(c_file_in)


cdef void file_close_write():

    file_out.write(stream_buf)
    file_out.close()


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
            eof, line = read_line()
            if eof:
                break

            line = sanitize_line(line)
            if re_match(RGX_IS_LOCAL_CIMPORT, line):
                line = line.split(".")[1].split(" ")[0]
                pxd_includes[pyx_file].add(line)

        file_close_read()

    SORT_INCLUDES = list(graphlib_TopologicalSorter(pxd_includes).static_order())


"""  extract header  """


cdef str sanitize_line(str line):
    line = line.split("#")[0]
    return re_sub(RGX_SANITIZE, "", line)


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
    return f"{pyx_file}{pyx_id}_{symbol}"


cdef void extract_header(str pxd_file):
    global PYX_FILES
    global pxd_public_symbols
    global pxd_variables
    global pxd_classes
    pxd_variables = []
    pxd_classes = {}

    cdef str filename = f"{DIR_TARGET}{pxd_file}.pxd"
    file_open_read(filename)

    cdef bint eof
    cdef str line
    cdef str clss
    cdef str symbol
    while True:
        eof, line = read_line()
        if eof:
            break

        line = sanitize_line(line)
        if re_match(RGX_IS_CLASS, line):
            clss = get_class_symbol(line)
            pxd_classes[clss] = []
            pxd_public_symbols[get_unique_id(pxd_file, clss)] = re_compile(r"\b{0}\b".format(clss))
        elif re_match(RGX_IS_FUNC_PXD, line):
            symbol = get_function_symbol(line)
            if symbol in SYMBOL_SKIP:
                continue
            pxd_public_symbols[get_unique_id(pxd_file, symbol)] = re_compile(r"\b{0}\b".format(symbol))
        elif re_match(RGX_IS_GLOB_VAR, line):
            symbol = get_variable_symbol(line)
            pxd_public_symbols[get_unique_id(pxd_file, symbol)] = re_compile(r"\b{0}\b".format(symbol))
            pxd_variables.append(line)
        elif re_match(RGX_IS_CLASS_VAR, line):
            pxd_classes[clss].append(line)

    file_close_read()


"""  process source  """


cdef void append_file_buffer(str line):
    global file_buf
    file_buf += line + "\n"


cdef void process_source(str pyx_file):
    global pyx_private_symbols
    global file_buf
    pyx_private_symbols = {}
    file_buf = ""

    cdef str filename = f"{DIR_TARGET}{pyx_file}.pyx"
    file_open_read(filename)

    append_file_buffer("")
    cdef str line
    for line in pxd_variables:
        append_file_buffer(line)
    append_file_buffer("")

    cdef bint eof
    cdef str symbol
    cdef str unique_id
    while True:
        eof, line = read_line()
        if eof:
            break

        line = sanitize_line(line)
        if re_match(RGX_IS_LOCAL_CIMPORT, line):
            continue
        if re_match(RGX_IS_PY_MAIN, line):
            break

        append_file_buffer(line)
        if re_match(RGX_IS_CLASS, line):
            symbol = get_class_symbol(line)
            unique_id = get_unique_id(pyx_file, symbol)
            if not unique_id in pxd_public_symbols:
                pyx_private_symbols[unique_id] = re_compile(r"\b{0}\b".format(symbol))
            if symbol in pxd_classes:
                for line in pxd_classes[symbol]:
                    append_file_buffer(line)
                append_file_buffer("")
                append_file_buffer("")
        elif re_match(RGX_IS_FUNC_PYX, line):
            symbol = get_function_symbol(line)
            if symbol in SYMBOL_SKIP:
                continue
            unique_id = get_unique_id(pyx_file, symbol)
            if not unique_id in pxd_public_symbols:
                pyx_private_symbols[unique_id] = re_compile(r"\b{0}\b".format(symbol))
        elif re_match(RGX_IS_GLOB_VAR, line):
            symbol = get_variable_symbol(line)
            unique_id = get_unique_id(pyx_file, symbol)
            if not unique_id in pxd_public_symbols:
                pyx_private_symbols[unique_id] = re_compile(r"\b{0}\b".format(symbol))

    file_close_read()

    for unique_id in pxd_public_symbols:
        file_buf = re_sub(pxd_public_symbols[unique_id], unique_id, file_buf)

    for unique_id in pyx_private_symbols:
        file_buf = re_sub(pyx_private_symbols[unique_id], unique_id, file_buf)

    write_file(file_buf)


"""  main """


cdef void entry(list[str] args):
    global PYX_FILES
    global pyx_id

    file_open_write(f"{OUTPUT_DIR}{PACKAGE_NAME}.pyx")

    sort_includes()

    cdef str pyx_file
    for pyx_id, pyx_file in enumerate(SORT_INCLUDES):

        extract_header(pyx_file)
        process_source(pyx_file)

    file_close_write()


cdef public int main_c(int argc, char **argv):
    cdef int i
    cdef list[str] args = []
    for i in range(argc):
        args.append(str(argv[i].decode("UTF-8")))

    entry(args)
