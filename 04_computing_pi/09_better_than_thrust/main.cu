#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <curand_kernel.h> // Inclure la bibliothèque curand
#include "../../nvtx_functions.h"
#include <cmath>
#include <thrust/count.h>
#include <thrust/device_ptr.h>

#define NB_points 134217728 // Number of points to process

inline void check_cuda_error(cudaError_t err) {
    if (err != cudaSuccess) {
        std::cerr << "CUDA Error: " << cudaGetErrorString(err) << std::endl;
        exit(EXIT_FAILURE);
    }
}

__global__ void init_curand_states_kernel(curandState *states, unsigned long long seed) {

    // Calculate the global thread index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // Check if the thread index is within bounds
    if (idx < NB_points) {
        // Initialize the random state for this thread
        curand_init(seed, idx, 0, &states[idx]);
    }
}

__global__ void calculate_points(curandState *states, int *countIn, int* nbpointsPerThreads) {

    // Calculate the global thread index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // TODO 1: Check if the thread index is within bounds
    if (idx < ...) {
        // Generate a random number between 0 and 1
        curandState state = states[idx];

        // TODO 2: Initialize a counter for the number of points processed and loop
        ...
        states[idx] = state; // Update the state

        // TODO 3: Perform warp-level reduction
        ...

        // TODO: Increment the count if inside the circle using atomic operations
        ...
    }
}

int main() {

    // Start of the flag "Set states for random"
    uint32_t red = 0xFF0000FF;   // color definition
    nvtxRangeId_t flag_init_Random = pushNvtxRangeWithColor("Set states for random", red);

    // Allocate memory for the random states on the device
    curandState *states;
    check_cuda_error(cudaMalloc(&states, sizeof(curandState) * NB_points));

    // Allocate memory for the countIn on the device
    int blockSize = 128; // Number of threads per block
    int numBlocks = (NB_POINTS + blockSize - 1) / blockSize; // Number of blocks
    init_curand_states_kernel<<<numBlocks, blockSize>>>(states, time(NULL));

    // End of the flag "Set states for random"
    popNvtxRange(flag_init_Random);

    // Start of the loop to test different numbers of points per thread
    for (int nbpointsPerThreads = 1; nbpointsPerThreads <= 16384; nbpointsPerThreads*=2) {

        // Allocate memory for the points processed and the number of points per thread
        int* d_countIn;
        int* d_nbCrossesPerThreads;

        // TODO 5: Determine the number of threads
        int nbThreads = ...

        check_cuda_error(cudaMalloc(&d_countIn, sizeof(int)));
        check_cuda_error(cudaMalloc(&d_nbCrossesPerThreads, sizeof(int)));

        check_cuda_error(cudaMemcpy(d_nbCrossesPerThreads, &nbCrossesPerThreads, sizeof(int), cudaMemcpyHostToDevice));

        // Start of the flag "Process and calculate PI"
        uint32_t green = 0x00FF00FF; // color definition
        char str[100];
        snprintf(str, sizeof(str), "Process and calculate PI with %d crosses per thread", nbCrossesPerThreads);
        nvtxRangeId_t flag_PROCESS_AND_CALCULATE_PI = pushNvtxRangeWithColor(str, green);

        // Start of the flag "Calculate crosses"
        numBlocks = (nbThreads + blockSize - 1) / blockSize; // Number of blocks
        char str2[50];
        snprintf(str2, sizeof(str2), "Calculate crosses with %d crosses per thread", nbCrossesPerThreads);
        nvtxRangeId_t flag_PROCESS_CROSSES = pushNvtxRangeWithColor(str2, red);

        // TODO 6: Launch the kernel to calculate crosses
        ...

        // End of the flag "Calculate crosses"
        popNvtxRange(flag_PROCESS_CROSSES);

        // Start of the flag "Count crosses and calculate PI"
        uint32_t blue = 0x0000FFFF; // color definition
        nvtxRangeId_t flag_Count_Crosses = pushNvtxRangeWithColor("Count crosses and calculate PI", blue);

        // TODO 7: Copy the result from device to host
        int h_countIn;
        check_cuda_error(cudaMemcpy(..., ..., sizeof(int), ...));

        // Calculate Pi
        double pi = ((double) h_countIn / (NB_CROSSES)) * 4;

        // End of the flag "Count crosses and calculate PI"
        popNvtxRange(flag_Count_Crosses);

        // End of the flag "Process and calculate PI"
        popNvtxRange(flag_PROCESS_AND_CALCULATE_PI);

        printf("For nbCrossesPerThreads = %d\nPi calculate : %f\nReal Pi = %f\nDifference : %f\n\n", nbCrossesPerThreads, pi, M_PI, fabs(pi - M_PI));

        // Free memory
        check_cuda_error(cudaFree(d_countIn));
        check_cuda_error(cudaFree(d_nbCrossesPerThreads));
    }
}