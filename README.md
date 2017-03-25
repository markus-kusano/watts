## README

Author: Markus Kusano

Abstract interpretation of LLVM IR using the APRON library.

## Building
The program is an LLVM `opt` pass. It is build using CMake. Since we are using
CMake, this likely requires LLVM version greater than or equal to 3.7 (tested
on 3.7).

Modify the CMakeLists file variable `APRON_PREFIX` to be the location where
Apron is installed

Assuming your LLVM library files are in a standard location (more on this
below), simply:

    mkdir build
    cd build
    cmake ../
    make

The result of the build process is an `.so` file, `libworklistAI.so`

If you need to tell CMake where LLVM lives, you need to add the option
`-DLLVM_DIR`, e.g., 

    cmake -DLLVM_DIR=/home/markus/src/install-3.2/share/llvm/cmake ../

The directory passed to `LLVM_DIR` should be the location where the LLVM CMake
files are (e.g., `LLVM-Config.cmake`).

### Slice Passes
The program-dependence graph slice options (`-aslice`) requires another `opt`
pass to be run prior to the abstract interpretation pass.

The options which should be used are `-z3 <z3 location> -assert -mdassert`.

https://github.com/markus-kusano/llvm-datalog

### Debug/Release Builds
To build with debugging symbols, use the follow CMake option:

    -DCMAKE_BUILD_TYPE=Debug

To build the (optimized) release build, use:

    -DCMAKE_BUILD_TYPE=Release 

## Running
To analyze a program, simply pass the `.so` file to `opt` and specify the input
file and abstract domain:

    opt -load <library file directory>/libWorklistAI.so -worklist-ai -box main.ll

This will analyze the file `main.ll` in the box abstract domain.

The `.ll` files can be created using an LLVM frontend for your language (e.g.,
`clang` for C).

## Options

    -box use the box abstract domain
    -oct use the octogon abstract domain
    -pkpoly use (strict) convex polyhedral abstract domain
    -pklineq use linear inequality abstract domain
    -nocombs combine all interferences into a single state
    -constraints Use constraint solver to prune infeasible interferences. Requires -z3
    -z3 Location of Z3 binary
    -nodebug disable debugging output on a debug build
