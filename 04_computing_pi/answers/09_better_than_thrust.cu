#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <curand_kernel.h> // Inclure la bibliothèque curand
#include "../../nvtx_functions.h"
#include <cmath>
#include <thrust/count.h>
#include <thrust/device_ptr.h>

#define NB_POINTS 134217728 // Number of points to process

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
    if (idx < NB_POINTS) {
        // Initialize the random state for this thread
        curand_init(seed, idx, 0, &states[idx]);
    }
}

__global__ void count_random_points_inside_circle_kernel(curandState *states, int *countIn, int* nb_points_per_threads) {

    // Calculate the global thread index
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    // Check if the thread index is within bounds
    if (idx < NB_POINTS / *nb_points_per_threads) {
        // Generate a random number between 0 and 1
        curandState state = states[idx];

        // Initialize a counter for the number of points processed and loop
        int counter = 0;
        for (int i = 0; i < *nb_points_per_threads; i++) {
            // Generate random numbers for x and y
            float x = curand_uniform(&state);
            float y = curand_uniform(&state);
            counter += (x * x + y * y) < 1.0f;
        }
        states[idx] = state; // Update the state

        // Perform warp-level reduction
        for (int offset = 16; offset > 0; offset /= 2) {
            counter += __shfl_down_sync(0xFFFFFFFF, counter, offset);
        }

        // Only one thread in each warp will write the result
        if ((threadIdx.x % warpSize) == 0) {;
            atomicAdd(countIn, counter); // Increment the count if inside the circle
        }
    }
}

int main() {

    // Start of the flag "Set states for random"
    uint32_t red = 0xFF0000FF;   // color definition
    nvtxRangeId_t flag_init_Random = pushNvtxRangeWithColor("Set states for random", red);

    // Allocate memory for the random states on the device
    curandState *states;
    check_cuda_error(cudaMalloc(&states, sizeof(curandState) * NB_POINTS));

    // Allocate memory for the countIn on the device
    int blockSize = 128; // Number of threads per block
    int numBlocks = (NB_POINTS + blockSize - 1) / blockSize; // Number of blocks
    init_curand_states_kernel<<<numBlocks, blockSize>>>(states, time(NULL));

    // End of the flag "Set states for random"
    popNvtxRange(flag_init_Random);

    // Start of the loop to test different numbers of points per thread
    for (int nb_points_per_threads = 1; nb_points_per_threads <= 16384; nb_points_per_threads*=2) {

        // Allocate memory for the points processed and the number of points per thread
        int* d_countIn;
        int* d_nb_points_per_threads;

        int nbThreads = NB_POINTS / nb_points_per_threads;

        check_cuda_error(cudaMalloc(&d_countIn, sizeof(int)));
        check_cuda_error(cudaMalloc(&d_nb_points_per_threads, sizeof(int)));

        check_cuda_error(cudaMemcpy(d_nb_points_per_threads, &nb_points_per_threads, sizeof(int), cudaMemcpyHostToDevice));

        // Start of the flag "Process and calculate PI"
        uint32_t green = 0x00FF00FF; // color definition
        char str[100];
        snprintf(str, sizeof(str), "Process and calculate PI with %d points per thread", nb_points_per_threads);
        nvtxRangeId_t flag_PROCESS_AND_CALCULATE_PI = pushNvtxRangeWithColor(str, green);

        // Start of the flag "Calculate points"
        numBlocks = (nbThreads + blockSize - 1) / blockSize; // Number of blocks
        char str2[50];
        snprintf(str2, sizeof(str2), "Calculate points with %d points per thread", nb_points_per_threads);
        nvtxRangeId_t flag_PROCESS_POINTS = pushNvtxRangeWithColor(str2, red);

        // Launch the kernel to calculate points
        count_random_points_inside_circle_kernel<<<numBlocks, blockSize>>>(states, d_countIn, d_nb_points_per_threads);

        // End of the flag "Calculate points"
        popNvtxRange(flag_PROCESS_POINTS);

        // Start of the flag "Count points and calculate PI"
        uint32_t blue = 0x0000FFFF; // color definition
        nvtxRangeId_t flag_Count_points = pushNvtxRangeWithColor("Count points and calculate PI", blue);

        // Copy the result from device to host
        int h_countIn;
        check_cuda_error(cudaMemcpy(&h_countIn, d_countIn, sizeof(int), cudaMemcpyDeviceToHost));

        // Calculate Pi
        double pi = ((double) h_countIn / (NB_POINTS)) * 4;

        // End of the flag "Count points and calculate PI"
        popNvtxRange(flag_Count_points);

        // End of the flag "Process and calculate PI"
        popNvtxRange(flag_PROCESS_AND_CALCULATE_PI);

        printf("For nb_points_per_threads = %d\nPi calculate : %f\nReal Pi = %f\nDifference : %f\n\n", nb_points_per_threads, pi, M_PI, fabs(pi - M_PI));

        // Free memory
        check_cuda_error(cudaFree(d_countIn));
        check_cuda_error(cudaFree(d_nb_points_per_threads));
    }
}