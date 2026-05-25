#include <cstdint>
#include <stdio.h>
#include <SDL2/SDL.h>
#include "runner.h"
#include "verilated.h"

uint16_t WIDTH_PIXELS = 640;
uint16_t HEIGHT_PIXELS = 480;
double SCALE = 1.5;

int main(int argc, char **argv) {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        printf("SDL_Init Error: %s\n", SDL_GetError());
        return 1;
    }

    SDL_Window* window = SDL_CreateWindow("Verilog Playground",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        WIDTH_PIXELS * SCALE, HEIGHT_PIXELS * SCALE,
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

    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_STREAMING, 640, 480);
    if (texture == nullptr) {
        printf("SDL_CreateTexture Error: %s\n", SDL_GetError());
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    auto* pixels = new uint8_t[WIDTH_PIXELS * HEIGHT_PIXELS * 3];
    for (int i = 0; i < WIDTH_PIXELS * HEIGHT_PIXELS * 3; i++) {
        pixels[i] = 0;
    }

    Verilated::commandArgs(argc, argv);
    runner_initialize();

    bool running = true;
    SDL_Event e;

    while (running) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_KEYUP) {
                if (e.key.keysym.sym == SDLK_ESCAPE) {
                    running = false;
                    continue;
                }
            }

            if (e.type == SDL_QUIT) {
                running = false;
            }
        }

        runner_simulate_frame(WIDTH_PIXELS, HEIGHT_PIXELS, pixels);

        // Display the completed frame
        SDL_UpdateTexture(texture, nullptr, pixels, WIDTH_PIXELS * 3);
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, nullptr, nullptr);
        SDL_RenderPresent(renderer);
        SDL_Delay(16);
    }

    delete[] pixels;
    runner_cleanup();

    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    printf("Finished!\n");
    return 0;
}
