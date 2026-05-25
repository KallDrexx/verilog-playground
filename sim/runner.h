#pragma once

#include <cstdint>

// Initializes the runner
void runner_initialize();

// Simulates a single frame for the runner. Assumes initialize ahs been called
void runner_simulate_frame(uint16_t width, uint16_t height, uint8_t* pixels);

// Cleans up any resources used by the runner
void runner_cleanup();
