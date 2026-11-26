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

__global__ void count_random_points_inside_circle_kernel(curandState *states,
         bool *sample_points_processed,
         const int sample_points)
{
    // Compute the global thread index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // Check if the thread index is within bounds
    if (idx < sample_points) {

        curandState state = states[idx];

        // Generate a random number between 0 and 1
        float x = curand_uniform(&state);
        float y = curand_uniform(&state);
        states[idx] = state; // Update the state

        //TODO 2: Check if the point (x, y) is inside the unit circle
        sample_points_processed[idx] = ... ;
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

    // Code-block to be tested with nsys
    uint32_t blue = 0xFF00FFFF;
    uint32_t green = 0x00FF00FF;
    nvtxRangeId_t flag_TOTAL_ID = pushNvtxRangeWithColor("Total time", green);
    nvtxRangeId_t flag_init_CPU_ID = pushNvtxRangeWithColor("Init CPU", blue);

    // Allocate memory for the h_sample_points_processed array on the host
    bool* h_sample_points_processed = new bool[sample_points];

    // Allocate memory for the curandState array on the device
    curandState *states;
    check_cuda_error(cudaMalloc(&states, sizeof(curandState)*sample_points));

    // Allocate memory for the sample_points_processed array on the device
    bool* d_sample_points_processed;
    check_cuda_error(cudaMalloc(&d_sample_points_processed,
            sizeof(bool)*sample_points));

    // Calculate grid and block size and launch kernel
    int blockSize = 128; // Number of threads per block
    int numBlocks = (sample_points + blockSize - 1) / blockSize; // Number of blocks

    // End of the flag "init CPU"
    popNvtxRange(flag_init_CPU_ID);

    // Start of the flag "Set states for random"
    uint32_t red = 0xFF0000FF;   // color definition
    nvtxRangeId_t flag_init_Random = pushNvtxRangeWithColor("Set states for random", red);

    // TODO 1: Initialize the random states for the device
    init_curand_states_kernel<<< ... , ... >>>(states, time(NULL), sample_points);

    // End of the flag "Set states for random"
    popNvtxRange(flag_init_Random);

    // Start of the flag "Process points"
    nvtxRangeId_t flag_process_points = pushNvtxRangeWithColor("Process points", red);

    count_random_points_inside_circle_kernel<<<numBlocks, blockSize>>>(states,
        d_sample_points_processed, sample_points);

    // End of the flag "Process points"
    popNvtxRange(flag_process_points);

    // Start of the flag "Count points and calculate PI"
    nvtxRangeId_t flag_count_points = pushNvtxRangeWithColor("Count points and calculate PI", blue);

    // Copy the results from device to host
    check_cuda_error(cudaMemcpy(h_sample_points_processed, d_sample_points_processed, sizeof(bool) * sample_points, cudaMemcpyDeviceToHost));

    // Count the number of points inside the circle
    int counter = 0;
    for (int i = 0; i < sample_points; i++) {
        if (h_sample_points_processed[i]) {
            counter++;
        }
    }

    // Calculate pi using the ratio of points inside the circle to total points
    const double pi = 4.0f * static_cast<double>(counter) / sample_points;

    // End of code-block
    popNvtxRange(flag_count_points);
    printf("%u sample points\n PI = %.15lf\n~PI = %.15lf\n", sample_points, pi, M_PI);

    // TODO 3:  Free memory
    ...

    // TODO 4:  Compile, execute and profile for every exercise with nsys using these commands (like in the presentation) :
    //          nsys profile --trace=cuda,nvtx --force-overwrite true -o output_name.nsys-rep a.out
    //          nsys-ui output_name.nsys-rep
    //          See total time in nsys ? compare with next exercises

    popNvtxRange(flag_TOTAL_ID);
}
