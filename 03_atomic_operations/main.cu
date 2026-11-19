// c/c++ libraries
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>

// custom functions
#include "../nvtx_functions.h"

__global__ void thread_init_kernel(
    unsigned int *array) {

    // global ID
    const unsigned int id = blockIdx.x * blockDim.x + threadIdx.x;

//    array[id] = threadIdx.x;
    array[id] = 1;
}

__global__ void add_threads_per_thread_block_kernel(const unsigned int *array, 
    unsigned int *block_sum) {
    
    // id \in [0, total_threads)
    const unsigned int id = blockIdx.x * blockDim.x + threadIdx.x;
    //const unsigned int id = threadIdx.x;  // works for a single block

    // Where does this memory is located? Registers/local: memory per thread
//    unsigned int sum = 0;

//    sum = sum + array[id];
//    sum += array[id];

    // blockIdx.x \in [0, total_blocks-1]

    // for all threads blockIdx.x is the same
    // If all threads start at the same time the value of block_sum = 0
//    block_sum[blockIdx.x] += array[id];

    // Race condition: multiple thread accessing to the memory at the same time
    // SOLUTION: Atomic operations, schedule the operations synchronously 
    atomicAdd(&block_sum[blockIdx.x] , array[id]);
}

int main() {

    // Code-block to be tested with nsys
//    uint32_t green = 0x00FF00FF;
//    nvtxRangeId_t flag = pushNvtxRangeWithColor("Total time", green);

    constexpr unsigned int blocks = 1000;
    constexpr unsigned int threads = 1024;
    constexpr unsigned int total_threads = blocks * threads;

    // char -> 2^8 - 1,  char \in [-128, 127],  unsigned char \in [0, 255]
    // short -> 2^16 - 1
    // int -> 2^32 - 1
    constexpr size_t array_size = total_threads * sizeof(unsigned int);
    constexpr size_t sum_size = blocks * sizeof(unsigned int);

    unsigned int *d_array;

    // block_sum :  memory space per block:
    // example for 3 blocks -> block_sum[0] = sum_block_0 (sum of 5 threads)
    // and 5 theads per block  block_sum[1] = sum_block_1 (sum of 5 threads)
    //                         block_sum[2] = sum_block_2 (sum of 5 threads)

    unsigned int *d_block_sum;

    // Allocate in global memory
    cudaMalloc(&d_array, array_size);
    cudaMalloc(&d_block_sum, sum_size);

    // Set the array to 0 before the sum stars
    cudaMemset(d_block_sum, sum_size, 0);

    // K1, array initialization, in this case all entries = 1
    thread_init_kernel<<<blocks, threads>>>(d_array);

    // K2, sum all entries per block
    add_threads_per_thread_block_kernel<<<blocks, threads>>>(d_array, d_block_sum);

    // Create array on the host to check results
    unsigned int *h_block_sum;
    cudaMallocHost(&h_block_sum, sum_size);

    cudaMemcpy(h_block_sum, d_block_sum, sum_size, cudaMemcpyDeviceToHost);
    for (int i = 0; i < blocks; ++i) {
        if ( h_block_sum[i] != threads) {
            printf("Error: block[%d] = %d\n", i, h_block_sum[i]);
        }
    }
    // Test the result for the first block but all of them must be the same
    printf("Example: block[%d] = %d\n", 0, h_block_sum[0]);

    cudaFreeHost(h_block_sum);

    cudaFree(d_array);
    cudaFree(d_block_sum);

//    popNvtxRange(flag);
}
