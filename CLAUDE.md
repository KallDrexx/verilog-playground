# Verilog Playground

Verilog learning utility. Compiles `.v` modules to C++ via Verilator.

## Structure
- `/` - C++ build files
- `/verilog/` - Verilog modules

## Commands
```bash
# Configure
cmake -DCMAKE_BUILD_TYPE=Debug -G Ninja -S . -B cmake-build-debug

# Build
make .

# Run
(cd cmake-build-debug && ./playground)
```

## Notes
- Parentheses in run command are required
- Add new .v files to /verilog/ directory
- Reconfigure cmake when adding modules