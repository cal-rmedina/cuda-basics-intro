// c/c++ libraries
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>

// custom functions
#include "../nvtx_functions.h"

__global__ void add_threads_per_thread_block_kernel(
    unsigned int *thread_block_sum) {
    
//    const unsigned int global_thread_id = blockIdx.x * blockDim.x +
//        threadIdx.x;

    thread_block_sum[blockIdx.x] += 1;
}

int main() {

    // Code-block to be tested with nsys
//    uint32_t green = 0x00FF00FF;
//    nvtxRangeId_t flag = pushNvtxRangeWithColor("Total time", green);

    constexpr unsigned int blocks = 100;
    constexpr unsigned int threads = 64;
    constexpr unsigned int total_threads = blocks * threads;

    unsigned int *d_thread_block_sum;
    constexpr size_t array_size = total_threads * sizeof(unsigned int);

    cudaMalloc(&d_thread_block_sum, array_size);

    cudaMemset(d_thread_block_sum, 0, array_size);

    add_threads_per_thread_block_kernel<<<blocks, threads>>>(d_thread_block_sum);

    // Free memory
    cudaFree(d_thread_block_sum);

//    popNvtxRange(flag);

}
