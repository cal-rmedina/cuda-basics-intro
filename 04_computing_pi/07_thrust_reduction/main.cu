// c/c++ libraries
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>

// CUDA libraries
#include <curand_kernel.h> // Inclure la bibliothèque curand

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
                        const int sample_points)
{

    // Calculate the global thread index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // Check if the thread index is within bounds
    if (idx < sample_points) {
        // Generate a random number between 0 and 1
        curandState state = states[idx];
        float x = curand_uniform(&state);
        float y = curand_uniform(&state);
        states[idx] = state; // Update the state

        // Check if the point is inside the circle
        pointsPrecessed[idx] = (x * x + y * y) < 1.0f;
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

    uint32_t blue = 0xFF00FFFF;
    nvtxRangeId_t flag_init_CPU_ID = pushNvtxRangeWithColor("init CPU", blue);

    // Allocate memory for the random states on the device
    curandState *states;
    check_cuda_error(cudaMalloc(&states, sizeof(curandState) * sample_points));

    // Initialize the count of points inside the circle
    int* d_pointsProcessed;
    check_cuda_error(cudaMalloc(&d_pointsProcessed, sizeof(int) * sample_points));

    // Calculate grid and block size and launch kernel
    int blockSize = 128; // Number of threads per block
    int numBlocks = (sample_points + blockSize - 1) / blockSize; // Number of blocks

    popNvtxRange(flag_init_CPU_ID);         // End of the flag "init CPU"

    // Initialize the random states
    uint32_t red = 0xFF0000FF;
    nvtxRangeId_t flag_init_Random = pushNvtxRangeWithColor("Set states for random", red);

    // Initialize the random states
    init_curand_states_kernel<<<numBlocks, blockSize>>>(states, time(NULL), sample_points);
    
    popNvtxRange(flag_init_Random);         // End of the flag "Set states for random"

    // Start of the flag "Process points"
    nvtxRangeId_t flag_PROCESS_POINTS = pushNvtxRangeWithColor("Process points", red);

    // TODO 1: Calculate the points
    ...

    popNvtxRange(flag_PROCESS_points);     // End of the flag "Process points"

    // Start of the flag "Count points and calculate PI"
    nvtxRangeId_t flag_Count_points = pushNvtxRangeWithColor("Count points and calculate PI", blue);

    // TODO 2: transform d_pointsProcessed to thrust::device_ptr
    ...


    // TODO 3: Reduce the array of the number of points inside the circle with thrust
    const int countCrossIn = ...

    // Calculate pi using the ratio of points inside the circle to total points
    const double pi = 4.0f * static_cast<double>(countCrossIn) / sample_points;
    printf("%u sample points\n PI = %.15lf\n~PI = %.15lf\n", sample_points, pi, M_PI);

    // Free memory
    check_cuda_error(cudaFree(d_pointsProcessed));
    check_cuda_error(cudaFree(states));
}
