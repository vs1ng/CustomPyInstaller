#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Python.h>

// The Python script to embed (will be replaced dynamically)
const char *embedded_script = 
    "# Embedded Python script\n"
    "print('Hello from custom executable!')\n"
    "import sys\n"
    "print(f'Python version: {sys.version}')\n";

int main(int argc, char *argv[]) {
    // Initialize Python interpreter
    Py_Initialize();

    // Set program name (optional, for sys.argv[0])
    wchar_t *program = Py_DecodeLocale(argv[0], NULL);
    if (program == NULL) {
        fprintf(stderr, "Fatal error: cannot decode argv[0]\n");
        exit(1);
    }
    Py_SetProgramName(program);

    // Run the embedded script
    int result = PyRun_SimpleString(embedded_script);
    if (result != 0) {
        PyErr_Print();
        fprintf(stderr, "Error running embedded Python script\n");
        Py_Finalize();
        PyMem_RawFree(program);
        exit(1);
    }

    // Clean up
    Py_Finalize();
    PyMem_RawFree(program);
    return 0;
}

// Function to read a file into a string (used by the builder)
char *read_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Error opening file");
        return NULL;
    }

    fseek(file, 0, SEEK_END);
    long length = ftell(file);
    fseek(file, 0, SEEK_SET);

    char *buffer = malloc(length + 1);
    if (!buffer) {
        fclose(file);
        return NULL;
    }

    fread(buffer, 1, length, file);
    buffer[length] = '\0';
    fclose(file);
    return buffer;
}
