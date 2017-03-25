cmake_minimum_required(VERSION 2.8.8)
project(LLVMDatalog)

find_package(LLVM REQUIRED CONFIG)

set(CXXFLAGS "-std=c++11 -Wall -fno-rtti")

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -DMK_DEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Wall -O2")

find_path(Z3_INC z3++.h)
message(STATUS ${Z3_INC})

# Modify this with the location of your apron installation
set(APRON_PREFIX "/home/markus/src/apron/install")
set(APRON_INCLUDE "${APRON_PREFIX}/include")
set(APRON_LIB "${APRON_PREFIX}/lib")
#set(APRON_MAIN_LIB "${APRON_LIB}/libapron_debug.a")
#set(APRON_BOX_LIB "${APRON_LIB}/libboxMPQ_debug.a")

link_directories(${APRON_LIB})

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
message(STATUS "CXXFLAGS: ${CXXFLAGS}")
message(STATUS "APRON_INCLUDE: ${APRON_INCLUDE}")
message(STATUS "APRON_LIB: ${APRON_LIB}")
#message(STATUS "APRON_LDFLAGS: ${APRON_LDFLAGS}")


# Set your project compile flags. E.g. if using the C++ header files you will
# need to enable C++11 support for your compiler.

add_definitions(${LLVM_DEFINITIONS} ${CXXFLAGS})
include_directories(${LLVM_INCLUDE_DIRS} ${APRON_INCLUDE} ${Z3_INC})

add_subdirectory(worklist-ai)
#add_subdirectory(pdg)
