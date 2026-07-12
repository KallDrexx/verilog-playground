cmake_minimum_required(VERSION 3.12)
cmake_policy(SET CMP0074 NEW)
project(verilog-playground)

cmake_policy(SET CMP0144 NEW)
find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if(NOT verilator_FOUND)
  message(
      FATAL_ERROR
      "Verilator was not found. Either install it, " +
      "or set the VERILATOR_ROOT environment variable"
    )
endif()

# Find SDL2
find_package(SDL2 REQUIRED COMPONENTS SDL2)

set(VERILOG_FOLDER ../verilog)

add_executable(test_pattern main.cpp runners/test_pattern_runner.cpp)
target_compile_features(test_pattern PUBLIC cxx_std_14)

# Link SDL2
target_include_directories(test_pattern PRIVATE)
target_link_libraries(test_pattern PRIVATE SDL2::SDL2)
target_compile_options(test_pattern PRIVATE )

verilate(test_pattern
        SOURCES ${VERILOG_FOLDER}/video_test_pattern.v
        INCLUDE_DIRS ${VERILOG_FOLDER}
        PREFIX Vvideo_test_pattern
        TRACE_VCD
        TRACE_STRUCTS
        TOP_MODULE video_test_pattern
)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
