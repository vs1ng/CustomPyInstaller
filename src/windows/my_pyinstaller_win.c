#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <Python.h>

const char *embedded_script = 
    "# Embedded Python script\n"
    "print('Hello from custom Windows executable!')\n"
    "import sys\n"
    "print(f'Python version: {sys.version}')\n";

int main(int argc, char *argv[]) {
    Py_Initialize();
    wchar_t *program = Py_DecodeLocale(argv[0], NULL);
    if (program == NULL) {
        fprintf(stderr, "Fatal error: cannot decode argv[0]\n");
        exit(1);
    }
    Py_SetProgramName(program);
    int result = PyRun_SimpleString(embedded_script);
    if (result != 0) {
        PyErr_Print();
        fprintf(stderr, "Error running embedded Python script\n");
        Py_Finalize();
        PyMem_RawFree(program);
        exit(1);
    }
    Py_Finalize();
    PyMem_RawFree(program);
    return 0;
}
