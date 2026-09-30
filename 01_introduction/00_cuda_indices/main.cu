#include <iostream>

#include <cuda_runtime.h>

__global__ void print_threads_id_kernel() {

    printf("block-%u, thread(%u, %u, %u)\n",
        blockIdx.x, threadIdx.x, threadIdx.y, threadIdx.z);
}

// TODO 0: Run the program, check 1st kernel lauch, modify to see output
//
//         How many threads per thread-block are launched?
//         How many blocks are launched?
//         How many output lines are expected (from the kernel)?
//         What are the thread-block & grid dimensions?
//         What is the usage of cudaDeviceSynchronize?

int main() {

    constexpr unsigned int threads = 1<<5;

    // Get GPU 0 properties (list available devices if > 1)
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    const unsigned int max_threads_per_block = prop.maxThreadsPerBlock;
    printf("Max thread-block size: %u\n", max_threads_per_block);

// TODO 1: Change the thread-block (1D -> 2D) & check the output
//
//         How many threads per thread-block are launched (2D)?
//         How many output lines are expected (from the kernel)?
//         What are the thread-block & grid dimensions?

    dim3 thread_block(threads);
//    dim3 thread_block(threads, threads);

    // 1st kernel launch
    print_threads_id_kernel<<<1, thread_block>>>();
//    cudaDeviceSynchronize();

    return 0;
}

