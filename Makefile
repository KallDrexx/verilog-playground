
.PHONY: build
build:
	cmake -DCMAKE_BUILD_TYPE=Debug -S sim -B sim/cmake-build-debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cmake --build sim/cmake-build-debug --target all -j ${shell nproc}

sim_test_pattern: build
	sim/cmake-build-debug/test_pattern
