# Custom PyInstaller

A simple custom tool to convert Python (.py) scripts into standalone executables for Linux and Windows, built from a Linux system. This project demonstrates embedding a Python script into a C program and linking it with the Python interpreter.

## Features
- Creates a Linux executable natively
- Cross-compiles a Windows executable using MinGW-w64
- Embeds Python scripts directly into the binary

## Limitations
- Does not handle Python module imports (e.g., `numpy`, `requests`)
- Requires manual setup for Windows Python libraries
- Larger executable size due to embedded Python interpreter

## Prerequisites
### For Linux
- GCC (`sudo apt-get install gcc`)
- Python 3 development files (`sudo apt-get install python3-dev`)
- Python 3.11 (adjust paths for your version)

### For Windows (Cross-Compilation)
- MinGW-w64 (`sudo apt-get install mingw-w64`)
- Windows Python libraries (e.g., `libpython311.a`, `python311.dll`, headers)
  - Download from Python's Windows embeddable package and place in `/usr/x86_64-w64-mingw32/`

## Directory Structure
custom-pyinstaller/
├── README.md
├── src/
│   ├── linux/
│   │   ├── my_pyinstaller.c       # C source for Linux
│   │   └── build_executable.sh    # Bash script to build Linux executable
│   └── windows/
│       ├── my_pyinstaller_win.c   # C source for Windows
│       └── build_executable_win.sh # Bash script to build Windows executable

## Usage

### Building a Linux Executable
1. Navigate to `src/linux/`
2. Make the build script executable:
   ```bash
   chmod +x build_executable.sh
Run the script with your Python file:
bash
./build_executable.sh your_script.py
Test the executable:
bash
./myapp
Building a Windows Executable (from Linux)
Navigate to src/windows/
Make the build script executable:
bash
chmod +x build_executable_win.sh
Ensure Windows Python libraries are in /usr/x86_64-w64-mingw32/
Run the script with your Python file:
bash
./build_executable_win.sh your_script.py
Test on Windows or via Wine:
bash
wine myapp.exe
Notes
Adjust Python version paths (e.g., -lpython3.11) based on your system.
For Windows, copy python311.dll alongside myapp.exe for it to run.
This is a basic implementation; for production use, consider PyInstaller.
Example
Create a test Python script (test.py):
python
print("This is a test executable!")
import sys
print(f"Running on: {sys.platform}")
Then:
Linux: ./build_executable.sh test.py
Windows: ./build_executable_win.sh test.py
