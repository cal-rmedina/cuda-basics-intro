# Problem

The goal of this exercise is to estimate PI using the Monte Carlo method.

# Monte Carlo Method

The Monte Carlo method for estimating π is a statistical technique that relies
on random sampling to approximate values. To understand it, imagine a square
with a quarter circle inscribed inside it, both with a radius of 1.  By
randomly generating points within the square and counting how many fall inside
the quarter circle (which occurs when the sum of the squares of the x and y
coordinates is less than or equal to 1), we can estimate the ratio of the area
of the quarter circle to the area of the square. Since the area of the square
is 1 and the area of the quarter circle is π/4, the ratio of points inside the
circle to the total number of points approaches π/4 as the number of points
increases. Multiplying this ratio by 4 gives an approximation of π (So, π = 4 *
(number of samples inside the circle / total samples)). The more points we
generate, the closer our estimate gets to the true value of π.

# Exercises

Do not pay attention to the nsys flags in the code. We will see later what it is and
how to use it.

## 1: π on CPU

The main problem of this exercise is that we use just one CPU core (serial).
So, the more samples we have, the longer it takes.

## 2: Start using the GPU

We initialize x and y coordinates in the CPU and then we copy them to the GPU.
The GPU will do the calculation of the points inside the circle and return the
result to the CPU. The CPU will then calculate the final value of PI using the
result from the GPU.

It's quicker than the previous version because the GPU is parallel and can do
many calculations at the same time.

## 3: Randomization in the GPU

We are copying the x and y coordinates from the CPU to the GPU and then copying
the resulting array from the GPU to the CPU.  After the analysis with nsys
tool, we see that *cudaMemcpy* is the actions that takes the most time. 

In this version we will generate the random numbers in the GPU. This is a
little bit more complicated because we need to use a random number generator
that is compatible with the GPU.

The random number generator will be used to generate the x and y coordinates in
the GPU. The GPU will then do the calculation of the points inside the circle
and return the result to the CPU.  The CPU will then calculate the final value
of PI using the result from the GPU after have copied the result from the GPU
to the CPU.

This version is better than the previous one because we don't need to copy
the x and y coordinates from the CPU to the GPU. The GPU will do everything by
itself.

## 4: Atomic operations

In the previous version we already saw that was the cudaMemcpy that took the
most time. We removed the copy of the x and y coordinates from the CPU to the
GPU. But we still have to copy the result from the GPU to the CPU.  For this
exercise, we want to avoid the copy of the process samples and directly count
the points inside the circle in the GPU. To do that, we will use atomics! That
allow, at the end of the code, to copy only one int instead of the whole array
of samples.

**Atomic operations**:  are a way to ensure that a variable is updated by only
one thread at a time. This is important because if two threads try to update
the same variable at the same time, it can cause problems. Atomics are used to
ensure that the variable is updated correctly and that the result is accurate.

The advantage of using atomics is that we don't need to copy the result from
the GPU to the CPU but the inconvenient is that blocked the writing of the
variable. So, if we have a lot of threads trying to update the same variable at
the same time, it can cause a bottleneck. This is why we need to be careful
when using atomics and to use them only when necessary.

## 5: Atomic operations + Warp

In the previous version we saw that the atomics are a way to ensure that a
variable is updated by only one thread at a time. But this can cause a
bottleneck if we have a lot of threads trying to update the same variable at
the same time.  In this version we will use the warp to avoid the bottleneck.
The warp is a group of 32 threads that are executed in parallel. So, if we have
a lot of threads trying to update the same variable at the same time, we can
use the warp to avoid the bottleneck.  You can transfer data between threads in
the same warp in a optimized way. This is called warp shuffle. The warp shuffle
is a way to transfer data between threads in the same warp without using shared
memory. This is important because shared memory is slower than registers
(memory of the thread) and we want to avoid using shared memory if possible.
The idea is to have a processed sample per thread and make a warp shuffle to
count in the first thread of the warp the number of points inside the circle
from the group of 32 threads. the first thread of the warp will then use the
atomics to update the variable that counts the total number of points inside
the circle.  With this way, you divided the number of atomics operations by 32.
So, if you have 1024 threads, you will have only 32 atomics operations instead
of 1024. This is a big improvement because the atomics are slow and we want to
avoid them if possible.

## 6: Thrust library (counting version)

The THRUST library is a C++ template library for CUDA that provides a
high-level interface for parallel algorithms and data structures. It is similar
to the C++ Standard Template Library (STL) but is designed to work with CUDA.
So, instead of writing the kernel to count the number of points inside the
circle, we can use the thrust library to do it for us in a parallel way. The
thrust library will use the GPU to do the calculation and will return the
result to the CPU.  The idea is to come back to the V3 (randomization in
the GPU) and use the thrust library to do the calculation of the points inside
the circle. The CPU will then calculate the final value of PI using the result
from the GPU after have copied the result from the GPU to the CPU.

## 7 : Thrust library (reduction version)

This version is the same as the previous one but we will use the thrust library
to do the reduction.  The thrust library has a function that does the reduction
for us. So, instead of writing the kernel to do the reduction, we can use the
thrust library to do it for us in a parallel way. The thrust library will use
the GPU to do the calculation and will return the result to the CPU.

## 8: Multiple sample per thread

After an analysis with ncu tools (we will see that later), you can see that the
bottleneck is th memory access. The memory access is slow and we want to avoid
it if possible.  An idea to avoid that, is to use multiple samples per thread.
The idea is to have a thread that will process multiple samples at the same
time. This way, you will reduce the number of memory accesses and you will
increase the performance of the code.

Once it's implemented, after checked the code in ncu, you can see that the
memory access is reduced and the performance is increased. The balance between
memory and compute is better.

## 9: Do better than thrust

If you wonder if THRUST libraries are the best way to do the reduction. The
answer is no. The thrust library is a good way to a quick implementation but it
is not the best way to go.  For example, we can wonder what happened if we mix
the multiple sample per thread, atomics and warp shuffle.  Once you have
implemented the code, you can check it with ncu and you will see that the
performance is better than the thrust library. Indeed, if you have 200 samples
per thread, you divided the number of atomics operations by 200*32 (warp size).
It's really a big improvement.
