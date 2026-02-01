# UCefView Third-party Build Scripts

This repository contains the scripts used to build and package the `CefViewCore` library, which is a core dependency for the UCefView project. These scripts handle the process of checking out the correct version of the source code, compiling it for various target platforms, and organizing the output into a standardized directory structure.

## Overview

The main purpose of these scripts is to automate the update process for the pre-compiled `CefViewCore` binaries. Each script is tailored for a specific operating system and architecture.

The general workflow for each script is as follows:
1.  **Read Configuration**: Reads repository URLs and version information from `ThirdParty-Config.txt`.
2.  **Fetch Source**: Clones the `CefViewCore` repository from GitHub and checks out a specific commit.
3.  **Compile**: Builds the project using CMake and the native toolchain for the target platform.
4.  **Package**: Copies the resulting headers, libraries, and other artifacts to the `../output/CefViewCore` directory.

## File Descriptions

-   `README.md`: This documentation file.
-   `ThirdParty-Config.txt`: A configuration file specifying the `CefViewCore` repository, the exact git commit to use, and the CEF (Chromium Embedded Framework) version. This ensures that builds are consistent and reproducible.
-   `Update-Win64.ps1`: A PowerShell script to build the dependencies for **Windows (x86_64)**. It performs a special step where it renames `UCefViewHelper.exe` to `UCefViewHelper.bin`.
-   `Update-Mac.sh`: A shell script to build dependencies for **macOS**. It compiles separate versions for `x86_64` and `arm64` and then uses `lipo` to create universal (multi-architecture) binaries for the framework and libraries.
-   `Update-Linux.sh`: A shell script to build the dependencies for **Linux (x86_64)**.
-   `Update-LinuxArm64.sh`: A shell script to build the dependencies for **Linux (arm64)**.

## How to Use

To update the third-party binaries, run the script corresponding to your target platform.

**Prerequisites:**
Before running the scripts, ensure you have the necessary build tools installed for your platform. This typically includes:
-   Git
-   CMake
-   A C++ compiler toolchain (e.g., Visual Studio on Windows, Xcode on macOS, Clang/GCC on Linux)

For more detailed prerequisites, please refer to the `CefViewCore` repository: [https://github.com/CefView/CefViewCore](https://github.com/CefView/CefViewCore)

### Windows

Open a PowerShell terminal and execute:
```powershell
./Update-Win64.ps1
```

### macOS

Open a terminal and execute:
```bash
./Update-Mac.sh
```

### Linux

Open a terminal and execute:
```bash
# For x86_64
./Update-Linux.sh

# For arm64
./Update-LinuxArm64.sh
```