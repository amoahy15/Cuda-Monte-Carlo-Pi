#include <stdio.h>
#include <stdlib.h>
#include <curand_kernel.h>

const unsigned long long THREADS = 32;
const unsigned long long BLOCK_SIZE = 256;

__global__ void pi_MC(float *totals, const int iterations);
int main(int argc, char **argv)
{
    if (argc != 2)
    {
        printf("Usage: ./PiMC <iterations>\n");
        return 1;
    }
    int iterations = atoi(argv[1]);
    if (iterations <= 0)
    {
        printf("Error: Number of iterations must be a positive integer.\n");
        return 1;
    }

    float *dev_a, *dev_b;
    dev_a = (float *)malloc(sizeof(float) * BLOCK_SIZE);
    cudaMalloc(&dev_b, sizeof(float) * BLOCK_SIZE);
    // Create CUDA events to measure the execution time
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Call the Pi Kernel
    cudaEventRecord(start);

    pi_MC<<<BLOCK_SIZE, THREADS>>>(dev_b, iterations);
    cudaEventRecord(stop);

    cudaMemcpy(dev_a, dev_b, sizeof(float) * BLOCK_SIZE, cudaMemcpyDeviceToHost);
    float elapsedTime;
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsedTime, start, stop);
    cudaFree(dev_b);
    printf("Time taken by program: %f seconds\n", elapsedTime / 1000);
    FILE *fp = fopen("cu_exec_time.csv", "a");
    if (fp == NULL)
    {
        printf("Error opening file\n");
        return 1;
    }

    fprintf(fp, "%.8f,%d\n", elapsedTime / 1000, iterations);
    fclose(fp);

    float count = 0;
    for (int i = 0; i < BLOCK_SIZE; i++)
    {
        count += dev_a[i];
    }
    unsigned long long tests = BLOCK_SIZE * iterations * THREADS;

    printf("Estimate of pi using CUDA: %.8f\n", 4.0 * count / tests);

    free(dev_a);

    return 0;
}
__global__ void pi_MC(float *totals, const int iterations)
{
    __shared__ float count[THREADS];
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    curandState_t states;
    curand_init(clock64(), tid, 0, &states);
    count[threadIdx.x] = 0;
    for (int i = 0; i < iterations; i++)
    {
        float x = curand_uniform(&states);
        float y = curand_uniform(&states);
        count[threadIdx.x] += 1 - int(x * x + y * y);
    }
    __syncthreads();
    for (int j = 1; j < blockDim.x; j *= 2)
    {
        int idx = 2 * j * threadIdx.x;
        if (idx < blockDim.x)
        {
            count[idx] += count[idx + j];
        }
        __syncthreads();
    }
    if (threadIdx.x == 0)
    {
        atomicAdd(&totals[blockIdx.x], count[0]);
    }
}