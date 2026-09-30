#include <iostream>

#include <cuda_runtime.h>

__global__ void print_threads_id_kernel() {

    // 1D output for cleaner visualization
    printf("block-%u, thread-%u\n", blockIdx.x, threadIdx.x);

/*
    // 3D output
    printf("block(%u, %u, %u) thread(%u, %u, %u)\n",
	blockIdx.x, blockIdx.y, blockIdx.z,
	threadIdx.x, threadIdx.y, threadIdx.z);
*/
}

// TODO 0: Run the program
//
//         0-a) How many threads per thread-block are launched?
//         0-b) How many blocks are launched?
//         0-c) How many output lines are expected (from the kernel)?
//         0-d) What are the thread-block & grid dimensions?
//         0-e) What is the usage of cudaDeviceSynchronize?

int main() {

    constexpr unsigned int threads = 1<<5;

    // Get GPU 0 properties (list available devices if > 1)
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    const unsigned int max_threads_per_block = prop.maxThreadsPerBlock;
    printf("Max thread-block size: %u\n", max_threads_per_block);

    dim3 thread_block(threads);
//    dim3 thread_block(threads, threads);

// TODO 1: Run the program with 2D thread-block (instead of 1D)
//
//         1-a) How many threads per thread-block are launched?
//         1-b) Can we launch 3D kernels?
//         1-c) What is the max number of threads per thread-block?

    // kernel launch
    print_threads_id_kernel<<<1, thread_block>>>();
//    cudaDeviceSynchronize();

    return 0;
}

