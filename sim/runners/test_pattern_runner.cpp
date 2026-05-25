#include "../runner.h"
#include "Vvideo_test_pattern.h"
#include <cstdint>

Vvideo_test_pattern* testPattern;

void runner_initialize()
{
    testPattern = new Vvideo_test_pattern;
    testPattern->clk = 0;
    testPattern->reset = 1;
    testPattern->eval();
    testPattern->reset = 0;
}

void runner_cleanup()
{
    delete testPattern;
}

void runner_simulate_frame(uint16_t width, uint16_t height, uint8_t *pixels)
{
    int pixelX = 0;
    int pixelY = 0;

    // Run full frame simulation until vsync goes high
    while (testPattern->vsync == 0) {
        testPattern->clk = !testPattern->clk;
        testPattern->eval();

        if (testPattern->clk == 1 && testPattern->display_on == 1) {
            int pixelIndex = (pixelY * width + pixelX) * 3;
            if (pixelIndex >= 0 && pixelIndex < width * height * 3) {
                pixels[pixelIndex] = testPattern->red;
                pixels[pixelIndex + 1] = testPattern->green;
                pixels[pixelIndex + 2] = testPattern->blue;
            }

            pixelX++;
            if (pixelX >= width) {
                pixelX = 0;
                pixelY++;
                if (pixelY >= height) {
                    pixelY = 0;
                }
            }
        }
    }

    // Continue toggling clock while vsync is high
    while (testPattern->vsync == 1) {
        testPattern->clk = !testPattern->clk;
        testPattern->eval();
    }
}
