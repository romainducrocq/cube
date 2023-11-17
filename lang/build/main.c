#include <Python.h>
#include "ccc/ccc.h"

int main(int argc, char **argv) {
    PyImport_AppendInittab("ccc", PyInit_ccc);
    Py_Initialize();
    PyImport_ImportModule("ccc");
    main_c(argc, argv);
    Py_Finalize();
    return 0;
}
