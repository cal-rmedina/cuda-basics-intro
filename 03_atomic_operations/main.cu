#include <cstdio>
#include <cuda_runtime.h>
#include "../nvtx_functions.h"

__global__ void add_threads_per_thread_block_kernel(
    unsigned int *thread_block_sum) {
    
    thread_block_sum[blockIdx.x] += 1;
}

int main() {

    // Code-block to be tested with nsys
//    uint32_t green = 0x00FF00FF;
//    nvtxRangeId_t flag_0 = pushNvtxRangeWithColor("Whole Code", green);

    constexpr unsigned int blocks = 100;
    constexpr unsigned int threads = 32;
    constexpr size_t array_size = blocks * sizeof(unsigned int);

    unsigned int *d_thread_block_sum;
    cudaMalloc(&d_thread_block_sum, array_size);
    cudaMemset(d_thread_block_sum, 0, array_size);  // Set vector to 0

    add_threads_per_thread_block_kernel<<<blocks, threads>>>(d_thread_block_sum);

    // TEST: checking output sum per block
    unsigned int *h_thread_block_sum;
    cudaMallocHost(&h_thread_block_sum, array_size);
    cudaMemcpy(h_thread_block_sum, d_thread_block_sum, array_size,
        cudaMemcpyDeviceToHost);
    for (unsigned int i = 0; i < blocks; ++i) {
        printf("sum block[%u] = %u\n", i, h_thread_block_sum[i]);
    }
    cudaFreeHost(h_thread_block_sum);

    cudaFree(d_thread_block_sum);   // Free memory device

//    popNvtxRange(flag_0);
}

// TODO 0: Profile the program with nsys and identify the most time-consuming operations.

// TODO 1: Run the program as provided. Change the number of threads per block
// and compare each block's output with the expected sum.

// TODO 2: Temporarily disable the kernel launch and create a reference array
// on the host containing the expected sum for each block. Compare it with the
// values produced by the kernel.

// TODO 3: Use atomicAdd to safely accumulate one contribution per thread into
// its block's sum. 

// TODO 4: Once the kernel is correct increase the number of blocks and threads per 
// block. Rerun the program and compare the results with the reference array
// using NVTX.

// TODO 5: Create a kernel that gives the sum the thread Ids: for example for
// thread-block size of 32 the sum must be 0 + 1 + ... + 31
