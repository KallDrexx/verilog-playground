cmake_minimum_required(VERSION 3.12)
cmake_policy(SET CMP0074 NEW)
project(verilog-playground)

cmake_policy(SET CMP0144 NEW)
find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if(NOT verilator_FOUND)
    message(
            FATAL_ERROR
            "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable"
    )
endif()

add_executable(playground main.cpp)
target_compile_features(playground PUBLIC cxx_std_14)
verilate(playground
        SOURCES verilog/video_sync_generator.v
        TRACE
        TRACE_STRUCTS
)
