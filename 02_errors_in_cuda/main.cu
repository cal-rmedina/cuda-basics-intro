#include <stdio.h>
#include <iostream>

// Errors in CUDA could be invisible. If you run the code the code will be
// executed but the results are wrong and the compiler doesn't help (yet)

__global__ void fill_vector_kernel(int* vector, const int elements) {

    // global thread ID
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < elements) vector[idx] = idx;
}

// --- HANDLE CUDA ERROR: called from host ---
inline void check_cuda_error(cudaError_t err) {
    if (err != cudaSuccess) {
        std::cerr << "CUDA Error: " << cudaGetErrorString(err) << std::endl;
        exit(EXIT_FAILURE);
    }
}

int main() {

    // Sample points, limited by the max unsigned int
    constexpr unsigned int elements = 1<<20;

    // TODO 2: Check that the size for the allocated array is correct
    size_t vector_size = elements*sizeof(short);

    int* d_vector;
    // BONUS QUESTION: Why doesn't the following call display any error?
    // check_cuda_error( cudaMalloc(&d_vector, vector_size) ); 
    cudaMalloc(&d_vector, vector_size);

    // TODO 3: Launch the kernel with a valid configuration
//    const int threads = ... ;
//    const int blocks  = ... ;

    fill_vector_kernel<<<1, elements>>>(d_vector, elements);

    int h_vector[elements];
    // TODO 4: Use check_cuda_error function for testing cudaMemcpy
//    check_cuda_error( cudaMemcpy(d_vector, h_vector, vector_size, cudaMemcpyDeviceToHost) );
    cudaMemcpy(h_vector, d_vector, vector_size, cudaMemcpyDeviceToHost);

    // Printing first and last 10 elements
    for(int i=0; i<10; i++)
        printf("vec[%d]=%d\n", i, h_vector[i]);

    for(int i=elements-10; i<elements; i++)
        printf("vec[%d]=%d\n", i, h_vector[i]);


    // TODO 1: Uncomment the cudaGetLastError() code,
    // compile and run the code again to see the errors

//    cudaError_t err = cudaGetLastError();
//    if (err != cudaSuccess) {
//        printf("CUDA Error: %s\n", cudaGetErrorString(err));
//    }

    cudaFree(d_vector);
}
