// Library added for testing
#include <cassert>
#include <iostream>

#include <cuda_runtime.h>

// Host code
void initialize_array_with_global_id(
    const unsigned int elements,
    unsigned int* h_array_id) {

    for (unsigned int i = 0; i < elements; ++i) {
        h_array_id[i] = i;
    }
}

// Device code (_kernel)
__global__ void initialize_array_with_global_id_kernel(
    const unsigned int elements,
    unsigned int* d_array_id) {

    const unsigned int tid =  blockIdx.x * blockDim.x + threadIdx.x;
    d_array_id[tid] = tid;
}

// TODO 0: Run the host code
//         0-a) How many cores are active filling the array?
//         0-b) What is the function of the assert after the function call?

int main() {

    // Elements and memory size
    constexpr unsigned int elements = 1 << 10;
    constexpr size_t elements_size = elements * sizeof(unsigned int);

    // Host array allocation
    unsigned int *h_array_id;
    cudaMallocHost(&h_array_id, elements_size);

    initialize_array_with_global_id( elements, h_array_id);

    // Checking that the host array is correctly set
    for (unsigned int i = 0; i < elements; ++i) {
        assert(h_array_id[i] == i);
    }

// TODO 1: Uncomment and run the device code
//
//         1-a) How many thread-blocks do we need to cover the whole array?
//         1-b) Are all the elements of the array covered?
//         1-c) Are we accessing elements out of bounds?
//
// Change the number of elements to a number that IS NOT MULTIPLE OF threads,
// modify if needed to work regardless the array size
//
//         1-d) Are there idle threads after the kernel modification?
//         1-e) Are we accessing elements out of bounds?
//         1-f) Do we need cudaDeviceSynchronize after the kernel launch?
/*
    // Device memory allocation
    unsigned int *d_array_id;
    cudaMalloc(&d_array_id, elements_size);

    // 1D thread-block size 
    constexpr unsigned int threads = 1 << 5;
    dim3 thread_block(threads);

    // Allocating enough threads to cover the array
    const unsigned int blocks = elements / threads;
//    const unsigned int blocks = (elements + threads - 1) / threads;

    // Kernel launch 1D grid and 1D thread-blocks
    initialize_array_with_global_id_kernel<<<blocks, thread_block>>>(elements, d_array_id);

    // Copy elements from device to host
    cudaMemcpy(h_array_id, d_array_id, elements_size,
        cudaMemcpyDeviceToHost);

    // Checking that the device array is correctly set
    for (unsigned int i = 0; i < elements; ++i) {
        assert(h_array_id[i] == i);
    }

    // Device memory free
    cudaFree(d_array_id);
*/

    // Host memory free
    cudaFreeHost(h_array_id);

    return 0;
}

