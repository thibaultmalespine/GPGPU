#include "student.hpp"

void allocateArraysCUDA(const int n, int **dev_a, int **dev_b, int **dev_res)
{
	HANDLE_ERROR(cudaMalloc(dev_a, n * sizeof(int)));
	HANDLE_ERROR(cudaMalloc(dev_b, n * sizeof(int)));
	HANDLE_ERROR(cudaMalloc(dev_res, n * sizeof(int)));

}

void copyFromHostToDevice(const int n, int *const a, int *const b,
						  int **dev_a, int **dev_b)
{
	HANDLE_ERROR(cudaMemcpy(*dev_a, a, n * sizeof(int), cudaMemcpyHostToDevice));
	HANDLE_ERROR(cudaMemcpy(*dev_b, b, n * sizeof(int), cudaMemcpyHostToDevice));
}

void launchKernel(const int n, const int *const dev_a,
				  const int *dev_b, int *const dev_res)
{
	sumArraysCUDA<<<n/127 + 1, 128>>>(n, dev_a, dev_b, dev_res);
}

void copyFromDeviceToHost(const int n, int *res, const int *const dev_res)
{
	HANDLE_ERROR(cudaMemcpy(res, dev_res, n * sizeof(int), cudaMemcpyDeviceToHost));
}

void freeArraysCUDA(int *const dev_a, int *const dev_b, int *const dev_res)
{
	HANDLE_ERROR(cudaFree(dev_a));
	HANDLE_ERROR(cudaFree(dev_b));
	HANDLE_ERROR(cudaFree(dev_res));
}

__global__ void sumArraysCUDA(const int n, const int *const dev_a,
				   const int *dev_b, int *const dev_res)
{
	int threadId = blockIdx.x * blockDim.x + threadIdx.x;

	if( threadId < n ){
		dev_res[threadId] = dev_a[threadId] + dev_b[threadId];
	}
}
