
.PHONY: build
build:
	cmake -DCMAKE_BUILD_TYPE=Debug -G Ninja -S sim -B sim/cmake-build-debug
	cmake --build sim/cmake-build-debug --target all -j ${shell nproc}

sim_test_pattern: build
	sim/cmake-build-debug/test_pattern
