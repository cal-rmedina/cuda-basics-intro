#include <iostream>
#include <cuda_runtime.h>

// Device (GPU) functions: kernels
// __global__ -> function called from the host (CPU) to the device (GPU)
__global__ void hello_from_thread_kernel() {

    printf("Hello from thread %u, block %u\n", threadIdx.x, blockIdx.x);
}

// Host (CPU) function
void hello_from_thread() {

    printf("Hello world from CPU\n");
}

// Main function (CPU)
int main() {

    // Host function
//    hello_from_thread();

    // Kernel launch
    hello_from_thread_kernel<<<2, 16>>>();
    cudaDeviceSynchronize();

    return 0;
}

