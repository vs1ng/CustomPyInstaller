#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 your_script.py"
    exit 1
fi

PY_SCRIPT=$1
OUTPUT="myapp"

# Check if Python script exists
if [ ! -f "$PY_SCRIPT" ]; then
    echo "Error: $PY_SCRIPT not found"
    exit 1
fi

# Read Python script and escape it for C string
SCRIPT_CONTENT=$(sed 's/\\/\\\\/g; s/"/\\"/g; s/^/    "/; s/$/\\n"/' "$PY_SCRIPT")

# Create temporary C file with embedded script
cat > temp_my_pyinstaller.c << EOL
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Python.h>

const char *embedded_script =
$SCRIPT_CONTENT;

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
EOL

# Compile the C code
gcc -o "$OUTPUT" temp_my_pyinstaller.c -I/usr/include/python3.11 -lpython3.11
if [ $? -eq 0 ]; then
    echo "Executable created: ./$OUTPUT"
    rm temp_my_pyinstaller.c
else
    echo "Compilation failed"
    rm temp_my_pyinstaller.c
    exit 1
fi
