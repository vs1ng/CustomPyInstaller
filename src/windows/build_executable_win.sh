#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 your_script.py"
    exit 1
fi

PY_SCRIPT=$1
OUTPUT="myapp.exe"

if [ ! -f "$PY_SCRIPT" ]; then
    echo "Error: $PY_SCRIPT not found"
    exit 1
fi

# Install MinGW-w64
if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo "Installing MinGW-w64..."
    sudo apt-get install mingw-w64
fi

# Download and prepare Windows Python (simplified, assumes pre-built Python libs)
# For simplicity, we'll assume Python 3.11 libs are available in /usr/x86_64-w64-mingw32/
PYTHON_LIB="/usr/x86_64-w64-mingw32/lib/libpython311.a"
PYTHON_INCLUDE="/usr/x86_64-w64-mingw32/include/python3.11"

if [ ! -f "$PYTHON_LIB" ]; then
    echo "Error: Windows Python library not found. Please install manually."
    exit 1
fi

# Escape Python script for C
SCRIPT_CONTENT=$(sed 's/\\/\\\\/g; s/"/\\"/g; s/^/    "/; s/$/\\n"/' "$PY_SCRIPT")

# Create temporary C file
cat > temp_my_pyinstaller_win.c << EOL
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
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

# Cross-compile for Windows
x86_64-w64-mingw32-gcc -o "$OUTPUT" temp_my_pyinstaller_win.c -I"$PYTHON_INCLUDE" -L"$PYTHON_LIB" -lpython311
if [ $? -eq 0 ]; then
    echo "Windows executable created: ./$OUTPUT"
    rm temp_my_pyinstaller_win.c
else
    echo "Compilation failed"
    rm temp_my_pyinstaller_win.c
    exit 1
fi
