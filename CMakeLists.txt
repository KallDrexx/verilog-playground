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

# Find SDL2
find_package(PkgConfig REQUIRED)
pkg_check_modules(SDL2 REQUIRED sdl2)
if(NOT SDL2_FOUND)
    message(FATAL_ERROR "SDL2 was not found")
endif()

add_executable(playground main.cpp)
target_compile_features(playground PUBLIC cxx_std_14)

# Link SDL2
target_include_directories(playground PRIVATE ${SDL2_INCLUDE_DIRS})
target_link_libraries(playground PRIVATE ${SDL2_LIBRARIES})
target_compile_options(playground PRIVATE ${SDL2_CFLAGS_OTHER})

verilate(playground
        SOURCES verilog/video_sync_generator.v verilog/video_test_pattern.v
        PREFIX Vvideo_test_pattern
        TRACE_VCD
        TRACE_STRUCTS
)
