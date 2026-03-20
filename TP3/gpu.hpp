#ifndef GPU_HPP
#define GPU_HPP

#include "utils/commonCUDA.hpp"

__global__ void kernel(int *data, int *count, uint32_t sampleNb, int N);
void gpu_histogramme(int* data, int* count, uint32_t sampleNb, uint32_t distributionSize, int N);

#endif // GPU_HPP