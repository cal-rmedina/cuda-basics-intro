#include <iostream>
#include <cuda_runtime.h>

// Device (GPU) functions: kernels
// __global__ -> function called from the host (CPU) to the device (GPU)
__global__ void hello_from_thread_kernel() {

    printf("Hello from thread %u, block %u with dim %u\n",
        threadIdx.x, blockIdx.x, blockDim.x );
}

// Host (CPU) function
void hello_from_thread() {

    printf("Hello world from CPU\n");
}

// Main function (CPU)
int main() {

    // Host function
    hello_from_thread();

    // Kernel launch <<<blocks, threads>>> 
    hello_from_thread_kernel<<<2, 4>>>();

    // Wating for the GPU to finish all the current tasks
    cudaDeviceSynchronize();

    return 0;
}

