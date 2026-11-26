// c/c++ libraries
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>

// CUDA libraries
#include <curand_kernel.h> // Inclure la bibliothèque curand

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
        const int sample_points, int samples_per_thread) {

    // Calculate the global thread index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

        // Generate a random number between 0 and 1
        curandState state = states[idx];

        states[idx] = state; // Update the state
        int count = 0;


        // TODO 1 Move the random points generation to the main loop
        //        allowing more computation per thread, using more random numbers per state
	    //        and having less atomic operations
        float x = curand_uniform(&state);
        float y = curand_uniform(&state);

        for (int i = 0; i < samples_per_thread; i++)
        {

            if (x * x + y * y < 1.0f) {
                count++;
            }
        }
        atomicAdd(countIn, count); // Increment the count
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
    nvtxRangeId_t flag_init_CPU_ID = pushNvtxRangeWithColor("init CPU", blue);

    // Allocate memory for the random states on the device
    curandState *states;
    check_cuda_error(cudaMalloc(&states, sizeof(curandState) * sample_points));

    // Initialize the count of points inside the circle
    int h_countIn = 0;

    // Allocate memory for the count of points inside the circle on the device
    int* d_countIn;
    check_cuda_error(cudaMalloc(&d_countIn, sizeof(int)));

    // Calculate grid and block size and launch kernel
    int blockSize = 128; // Number of threads per block

    // TODO 2 Execute the program and profile with ncu to test your performances,
    //        enter into the profiling repo or execute it with the right path from here
    //        $ncu-ui 04_no_optimization.ncu-rep

    // TODO 3 Now each thread will sample multiple points, increasing their computation time,
    // 	      but you need to update the number of blocks to match the desired sample points (2^25),
    // 	      please use samples_per_thread as power of 2 for simplicity
    unsigned int samples_per_thread = 1<<0;
    int numBlocks = (sample_points + blockSize - 1) / blockSize; // Number of blocks


    // TODO 4 Profile again with ncu and see the difference
    //        ncu-ui 04_optimized.ncu-rep

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

    // Calculate the points
    count_random_points_inside_circle_kernel<<<numBlocks, blockSize>>>(states, d_countIn, sample_points, samples_per_thread);

    // End of the flag "Process points"
    popNvtxRange(flag_PROCESS_POINTS);

    // Start of the flag "Calculate PI"
    nvtxRangeId_t flag_Count_points = pushNvtxRangeWithColor("Calculate PI", blue);

    // Copy the count of points inside the circle from device to host
    check_cuda_error(cudaMemcpy(&h_countIn, d_countIn, sizeof(int), cudaMemcpyDeviceToHost));

    // Calculate pi using the ratio of points inside the circle to total points
    const double pi = 4.0f * static_cast<double>(h_countIn) / sample_points;

    // End of code-block
    popNvtxRange(flag_Count_points);
    printf("%u sample points, %u samples_per_thread \n PI = %.15lf\n~PI = %.15lf\n", sample_points, samples_per_thread, pi, M_PI);

    // Free memory
    check_cuda_error(cudaFree(states));
    check_cuda_error(cudaFree(d_countIn));
    popNvtxRange(flag_TOTAL_ID);
}
