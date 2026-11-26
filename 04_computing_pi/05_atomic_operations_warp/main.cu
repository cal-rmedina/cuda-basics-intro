// c/c++ libraries
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>

// CUDA libraries
#include <curand_kernel.h>

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

__global__ void count_random_points_inside_circle_kernel(curandState *states, int* countIn,
        const int sample_points) {

    // Calculate the global thread index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // Check if the thread index is within bounds
    if (idx < sample_points) {

        // Generate a random number between 0 and 1 and check if it's inside the circle
        curandState state = states[idx];
        float x = curand_uniform(&state);
        float y = curand_uniform(&state);
        states[idx] = state; // Update the state

        // Check if the point is inside the circle
        int threadCount = x * x + y * y < 1.0f;

        // TODO 1: Perform warp-level reduction
        ...

        // TODO 2: Perform atomic operation
        ...
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
    constexpr unsigned int sample_points = 1<<25;

    // Start of the flag "init CPU"
    uint32_t blue = 0xFF00FFFF;   // color definition
    uint32_t green = 0x00FF00FF;
    nvtxRangeId_t flag_TOTAL_ID = pushNvtxRangeWithColor("Total time", green);
    nvtxRangeId_t flag_init_CPU_ID = pushNvtxRangeWithColor("init CPU", blue);

    // Allocate memory for the random states on the device
    int h_countIn = 0;

    // Allocate memory for the random states on the device
    curandState *states;
    check_cuda_error(cudaMalloc(&states, sizeof(curandState) * sample_points));

    // Initialize the count of points inside the circle
    int* d_countIn;
    check_cuda_error(cudaMalloc(&d_countIn, sizeof(int)));

    // Calculate grid and block size and launch kernel
    int blockSize = 128; // Number of threads per block
    int numBlocks = (sample_points + blockSize - 1) / blockSize; // Number of blocks

    // End of the flag "init CPU"
    popNvtxRange(flag_init_CPU_ID);

    // Start of the flag "Set states for random"
    uint32_t red = 0xFF0000FF;   // color definition
    nvtxRangeId_t flag_init_Random = pushNvtxRangeWithColor("Set states for random", red);

    // Initialize the random states
    init_curand_states_kernel<<<numBlocks, blockSize>>>(states, time(NULL), sample_points);

    // End of the flag "Set states for random"
    popNvtxRange(flag_init_Random);

    // Start of the flag "Process points"
    nvtxRangeId_t flag_PROCESS_POINTS = pushNvtxRangeWithColor("Process points", red);

    // TODO 3: Calculate the points
    ...

    // End of the flag "Process points"
    popNvtxRange(flag_PROCESS_POINTS);

    // Start of the flag "Calculate PI"
    nvtxRangeId_t flag_Count_points = pushNvtxRangeWithColor("Calculate PI", blue);

    // TODO 4: Copy the result from device to host
    check_cuda_error(cudaMemcpy(..., ..., sizeof(int), ...));

    // Calculate pi using the ratio of points inside the circle to total points
    const double pi = 4.0f * static_cast<double>(h_countIn) / sample_points;

    // End of code-block
    popNvtxRange(flag_Count_points);
    printf("%u sample points\n PI = %.15lf\n~PI = %.15lf\n", sample_points, pi, M_PI);

    // Free memory
    check_cuda_error(cudaFree(states));
    check_cuda_error(cudaFree(d_countIn));
    popNvtxRange(flag_TOTAL_ID);
}
