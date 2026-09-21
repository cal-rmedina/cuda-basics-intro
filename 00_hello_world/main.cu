#include <iostream>

#include <cuda_runtime.h>

__global__ void hello_from_thread_kernel() {

    printf("Hello from thread %u\n", threadIdx.x);
}

int main() {

    // Kernel launch
    hello_from_thread_kernel<<<1, 32>>>();
    cudaDeviceSynchronize();

    return 0;
}

