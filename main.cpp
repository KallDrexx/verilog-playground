#include <stdio.h>
#include <SDL2/SDL.h>
#include "verilated.h"
#include "Vvideo_test_pattern.h"

void simulateFrame(Vvideo_test_pattern* testPattern, Uint8* pixels, int& pixelX, int& pixelY) {
    // Run full frame simulation until vsync goes high
    while (testPattern->vsync == 0) {
        testPattern->clk = !testPattern->clk;
        testPattern->eval();

        if (testPattern->clk == 1 && testPattern->display_on == 1) {
            int pixelIndex = (pixelY * 256 + pixelX) * 3;
            if (pixelIndex >= 0 && pixelIndex < 256 * 240 * 3) {
                pixels[pixelIndex] = testPattern->red;
                pixels[pixelIndex + 1] = testPattern->green;
                pixels[pixelIndex + 2] = testPattern->blue;
            }
            
            pixelX++;
            if (pixelX >= 256) {
                pixelX = 0;
                pixelY++;
                if (pixelY >= 240) {
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

int main(int argc, char **argv) {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        printf("SDL_Init Error: %s\n", SDL_GetError());
        return 1;
    }

    SDL_Window* window = SDL_CreateWindow("Verilog Playground",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        800, 600,
                                        SDL_WINDOW_SHOWN);
    if (window == nullptr) {
        printf("SDL_CreateWindow Error: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (renderer == nullptr) {
        printf("SDL_CreateRenderer Error: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_STREAMING, 256, 240);
    if (texture == nullptr) {
        printf("SDL_CreateTexture Error: %s\n", SDL_GetError());
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    Uint8* pixels = new Uint8[256 * 240 * 3];
    for (int i = 0; i < 256 * 240 * 3; i++) {
        pixels[i] = 0;
    }

    Verilated::commandArgs(argc, argv);
    const auto testPattern = new Vvideo_test_pattern;

    bool running = true;
    SDL_Event e;
    testPattern->clk = 0;
    testPattern->reset = 1;
    testPattern->eval();
    testPattern->reset = 0;
    
    int pixelX = 0;
    int pixelY = 0;

    while (running) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                running = false;
            }
        }

        simulateFrame(testPattern, pixels, pixelX, pixelY);
        
        // Display the completed frame
        SDL_UpdateTexture(texture, nullptr, pixels, 256 * 3);
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, nullptr, nullptr);
        SDL_RenderPresent(renderer);
        
        pixelX = 0;
        pixelY = 0;
        
        SDL_Delay(16);
    }

    delete[] pixels;
    delete testPattern;

    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    printf("Finished!\n");
    return 0;
}
