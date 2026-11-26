// c/c++ libraries
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>

// CUDA libraries
#include <curand_kernel.h>

// THRUST libraries
#include <thrust/count.h>
#include <thrust/device_ptr.h>

// custom functions
#include "../../nvtx_functions.h"

// --- CUDA KERNELS: called from host executed on device --- 
__global__ void init_curand_states_kernel(curandState *states, unsigned long
                        long seed, const int sample_points)
{
    // Compute the global thread index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // Check if the thread index is within bounds
    if (idx < sample_points) {

        // Initialize the random state for this thread
        curand_init(seed, idx, 0, &states[idx]);
    }
}

__global__ void calculate_points(curandState *states, int *pointsPrecessed,
        int* samples_per_thread, const int sample_points) {

    // Calculate the global thread index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // TODO 1: Check if the thread index is within bounds
    if (idx < ...) {
        // Generate a random number between 0 and 1
        curandState state = states[idx];

        // TODO 2: Initialize a counter for the number of points processed and loop to generate random numbers and check if they are inside the circle
        ...
        states[idx] = state; // Update the state
    }
}

// --- HANDLE CUDA ERROR: called from host ---
inline void check_cuda_error(cudaError_t err) {
    if (err != cudaSuccess) {
        std::cerr << "CUDA Error: " << cudaGetErrorString(err) << std::endl;
        exit(EXIT_FAILURE);
    }
}


int main() {

    // Sample points, limited by the max unsigned int
    constexpr unsigned int sample_points = 1<<20;

    // Start of the flag "Set states for random"
    uint32_t red = 0xFF0000FF;   // color definition
    nvtxRangeId_t flag_init_Random = pushNvtxRangeWithColor("Set states for random", red);

    // Allocate memory for the random states on the device
    curandState *states;
    check_cuda_error(cudaMalloc(&states, sizeof(curandState) * sample_points));

    // Calculate grid and block size and launch kernel
    int blockSize = 128; // Number of threads per block
    int numBlocks = (sample_points + blockSize - 1) / blockSize; // Number of blocks

    // Set the random states
    init_curand_states_kernel<<<numBlocks, blockSize>>>(states, time(NULL), sample_points);

    // End of the flag "Set states for random"
    popNvtxRange(flag_init_Random);

    // Start a loop to test different numbers of points per thread
    for (int samples_per_thread = 1; samples_per_thread <= 16384; samples_per_thread*=2) {

        // Allocate memory for the points processed and the number of points per thread
        int* d_pointsProcessed;
        int* d_samples_per_thread;

        // TODO 3: Determine the number of threads needed
        int nbThreads = ...

        // TODO 4: Allocate memory for the samples processed and the number of samples per thread
        ...

        // Copy the number of points per thread to the device
        check_cuda_error(cudaMemcpy(d_samples_per_thread, &samples_per_thread, sizeof(int), cudaMemcpyHostToDevice));

        // Start of the flag "Process and calculate PI"
        uint32_t green = 0x00FF00FF; // color definition
        char str[100];
        snprintf(str, sizeof(str), "Process and calculate PI with %d points per thread", samples_per_thread);
        nvtxRangeId_t flag_PROCESS_AND_CALCULATE_PI = pushNvtxRangeWithColor(str, green);

        // Start of the flag "Calculate points"
        numBlocks = (nbThreads + blockSize - 1) / blockSize; // Number of blocks
        char str2[50];
        snprintf(str2, sizeof(str2), "Calculate points with %d points per thread", samples_per_thread);
        nvtxRangeId_t flag_PROCESS_POINTS = pushNvtxRangeWithColor(str2, red);

        // TODO 5: Calculate the points
        ...

        // End of the flag "Calculate points"
        popNvtxRange(flag_PROCESS_CROSSES);

        // Start of the flag "Count crosses and calculate PI"
        uint32_t blue = 0x0000FFFF; // color definition
        nvtxRangeId_t flag_Count_Crosses = pushNvtxRangeWithColor("Count crosses and calculate PI", blue);

        // TODO 6: transform d_crossesProcessed to thrust::device_ptr
        ...

        // TODO 7: Reduce the array of the number of crosses inside the circle with thrust
        const int countCrossIn = ...

        // Calculate pi using the ratio of points inside the circle to total points
        const double pi = 4.0f * static_cast<double>(countCrossIn) / sample_points;

        // End of the flag "Count crosses and calculate PI"
        popNvtxRange(flag_Count_Crosses);

        // End of the flag "Process and calculate PI"
        popNvtxRange(flag_PROCESS_AND_CALCULATE_PI);

        printf("Samples per thread = %d, total sample points: %u\n", samples_per_thread, sample_points);
        printf(" PI = %.15lf\n~PI = %.15lf\n\n", pi, M_PI);

        // Free memory
        check_cuda_error(cudaFree(d_crossesProcessed));
        check_cuda_error(cudaFree(d_samples_per_thread));
    }
}
