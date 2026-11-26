// c/c++ libraries
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>

// custom functions
#include "../../nvtx_functions.h"

// --- CUDA KERNELS: called from host executed on device --- 
__global__
void count_random_points_inside_circle_kernel(const float* sample_point_x,
    const float* sample_point_y, int* sample_point_processed,
    const int sample_points)
{

    // TODO 1: Calculate the global thread index
    int global_thread_id = ... ;

    // TODO 1: Check if the global thread index is within bounds
    if (global_thread_id < ... ) {

        float process = 
            sample_point_x[global_thread_id] * sample_point_x[global_thread_id]
          + sample_point_y[global_thread_id] * sample_point_y[global_thread_id];

        // Check if the point is inside the quarter circle
        if (process < 1.0f)  sample_point_processed[global_thread_id] = 1;
    }
}

int main() {

    uint32_t green = 0x00FF00FF;

    nvtxRangeId_t flag_TOTAL_ID = pushNvtxRangeWithColor("Total time", green);

    // Sample points, limited by the max unsigned int
    constexpr unsigned int sample_points = 1<<25;

    // Code-block to be tested with nsys
    uint32_t blue = 0xFF0000FF;
    nvtxRangeId_t Flag_Init_CPU = pushNvtxRangeWithColor("Init CPU", blue);

    // Allocate host memory for and processed sample points
    float* h_sample_point_x = new float[sample_points];
    float* h_sample_point_y = new float[sample_points];

    unsigned int* h_sample_point_Processed = new unsigned int[sample_points];

    // Generate random coordinates for sample_point_ between 0 and 1
    for (unsigned int i = 0; i < sample_points; i++) {
        h_sample_point_x[i] = static_cast<float>(rand()) / RAND_MAX;
        h_sample_point_y[i] = static_cast<float>(rand()) / RAND_MAX;
    }

    float* d_sample_point_x, *d_sample_point_y;
    int* d_sample_point_Processed;;

    // TODO 2: Allocate device memory for coordinates and processed sample points
    size_t sample_points_float = ... * sizeof(float);
    size_t sample_points_int = ... * sizeof(int);

    check_cuda_error(cudaMalloc(&d_sample_point_x, sample_points_float));
    check_cuda_error(cudaMalloc(&d_sample_point_y, sample_points_float));
    check_cuda_error(cudaMalloc(&d_sample_point_Processed, sample_points_int));

    // TODO 2: Initialize device memory for processed sample_point_ (sample_point_Processed)
    check_cuda_error(cudaMemset(d_sample_point_Processed, 0, ... ));

    // TODO 2: Copy host memory to device memory (sample_point_ coordinates)
    check_cuda_error(cudaMemcpy( ... , ... , sample_points_float, cudaMemcpyHostToDevice));
    check_cuda_error(cudaMemcpy( ... , ... , sample_points_float, cudaMemcpyHostToDevice));

    // End of code-block
    popNvtxRange(Flag_Init_CPU);

    // TODO 3: Launch the kernel to calculate sample points
    int block_size = ...; // Number of threads per block
    int num_blocks = ...; // Number of blocks

    // Code-block to be tested with nsys
    uint32_t red = 0xFF0000FF;   // color definition
    nvtxRangeId_t Flag_Kernel = pushNvtxRangeWithColor("Kernel", red);

    count_random_points_inside_circle_kernel<<<num_blocks, block_size>>>(d_sample_point_x, d_sample_point_y, d_sample_point_Processed, sample_points);

    // End of code-block
    popNvtxRange(Flag_Kernel);

    // Code-block to be tested with nsys
    nvtxRangeId_t Flag_Calculate_Pi = pushNvtxRangeWithColor("Calculate Pi", blue);

    // TODO 3 Copy processed sample points from device to host
    check_cuda_error(cudaMemcpy(..., ..., sample_points_int, ...));

    // Count the number of sample points inside the quarter circle
    unsigned int counter = 0;
    for (unsigned int i = 0; i < sample_points; i++)
        if (h_sample_point_Processed[i])  counter++;

    // Calculate pi using the ratio of points inside the circle to total points
    double pi = 4.0f * static_cast<double>(counter) / sample_points;

    // End of code-block
    popNvtxRange(Flag_Calculate_Pi);
    printf("%u sample points\n PI = %.15lf\n~PI = %.15lf\n", sample_points, pi, M_PI);

    delete[] h_sample_point_x;
    delete[] h_sample_point_y;
    delete[] h_sample_point_Processed;
    // TODO: Free CUDA allocated memory
    ...
    ...
    ...

    popNvtxRange(flag_TOTAL_ID);
}

