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

void two_vec_addition(
    const unsigned int elements,
    const unsigned int* h_a,
    const unsigned int* h_b,
    unsigned int* h_c) {

    for (unsigned int i = 0; i < elements; ++i) {
        h_c[i] = h_a[i] + h_b[i];
    }
}

// Device code (_kernel)
__global__ void initialize_array_with_global_id_kernel(
    const unsigned int elements,
    unsigned int* d_array_id) {

    const unsigned int tid =  blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < elements) {
        d_array_id[tid] = tid;
    }
}

__global__ void two_vec_addition_kernel(
    const unsigned int elements,
    const unsigned int* d_a,
    const unsigned int* d_b,
    unsigned int* d_c) {

    const unsigned int tid =  blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < elements) {
        d_c[tid] = d_a[tid] + d_b[tid];
    }
}

// TODO 0: Run the host code, once it runs uncomment the printf and run again
//         0-a) Does the vector "c" need initialization?
//         Uncomment the line with the assert 
//         0-b) Can you spot the error that doesn't allow the code to finish?
//         If needed, uncomment the line with the printf
//         0-c) What is the usage of the word "const" on the function definitions?
//         0-d) What is the function of the assert after the function call?

int main() {

    // Elements and memory size
    constexpr unsigned int elements = 1 << 10;
    constexpr size_t elements_size = elements * sizeof(unsigned int);

    // Host array allocation, 3 arrays needed
    unsigned int *h_a;
    unsigned int *h_b;
    unsigned int *h_c;
    cudaMallocHost(&h_a, elements_size);
    cudaMallocHost(&h_b, elements_size);
    cudaMallocHost(&h_c, elements_size);

    // Element initialization for arrays a & b
    initialize_array_with_global_id( elements, h_a);
    initialize_array_with_global_id( elements, h_b);

    two_vec_addition( elements, h_a, h_b, h_c);

    // Checking that the host array is correctly set
    for (unsigned int i = 0; i < elements; ++i) {

        // Printing output for visual inspection
//        printf("c[%u] = %u, expected: %u\n", i, h_c[i], 2*i );

//        assert(h_c[i] == i);
    }

// TODO 1: Uncomment and run the device code
//
//         1-a) What is the device currently doing?
//         1-b) Discuss the way to execute the sum on the device
//         1-c) Where does the data (arrays) should be to be used by
//              two_vec_addition_kernel?
/*
    // Set host vector to 0 for fair comparison 
    for (unsigned int i = 0; i < elements; ++i) {
        h_c[i] = 0;
    }

    // Device memory allocation
    unsigned int *d_a;
    unsigned int *d_b;
    unsigned int *d_c;
    cudaMalloc(&d_a, elements_size);
    cudaMalloc(&d_b, elements_size);
    cudaMalloc(&d_c, elements_size);

//    // 1D thread-block size 
//    constexpr unsigned int threads = 1 << 5;
//    dim3 thread_block(threads);
//
//    // Allocating enough threads to cover the array
//    const unsigned int blocks = (elements + threads - 1) / threads;
//
//    // Copy elements from ??? to ???
//    cudaMemcpy(h_a, d_a, elements_size, cudaMemcpyDeviceToHost);
//    cudaMemcpy(d_a, h_a, elements_size, cudaMemcpyHostToDevice);

    // Checking that the device array is correctly set
    for (unsigned int i = 0; i < elements; ++i) {
        assert(h_c[i] == 0);
    }

    // Device memory free
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
*/

    // Host memory free
    cudaFreeHost(h_a);
    cudaFreeHost(h_b);
    cudaFreeHost(h_c);

    return 0;
}

