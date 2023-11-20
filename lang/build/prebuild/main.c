#include <Python.h>
#include "prebuild/prebuild.h"

int main(int argc, char **argv) {
    PyImport_AppendInittab("prebuild", PyInit_prebuild);
    Py_Initialize();
    PyImport_ImportModule("prebuild");
    int ret = main_c(argc, argv);
    Py_Finalize();
    return ret;
}
