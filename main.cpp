#include <stdio.h>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vvideo_sync_generator.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    const std::unique_ptr<VerilatedContext> context{new VerilatedContext};
    const auto generator = new Vvideo_sync_generator;

    Verilated::traceEverOn(true);
    const auto trace = new VerilatedVcdC;
    generator->trace(trace, 99);  // Trace 99 levels of hierarchy
    trace->open("waveform.vcd");  // Output file name

    generator->clk = 1;
    for (int x = 0; x < 200000; x++) {
        generator->clk = !generator->clk;
        generator->reset = x < 20;
        generator->eval();
        trace->dump(x);
    }

    trace->close();

    delete trace;
    delete generator;
}
