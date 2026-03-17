#include "student.hpp"

#include "utils/chronoGPU.hpp"
#include "utils/commonCUDA.hpp"

__device__ float clampfGPU(float n, float lower, float upper)
{
    return fmaxf(lower, fminf(n, upper));
}


__global__ void kernelComputeGPU(
    uchar* in, uchar* out,
    int width, int height,
    float* kernel, int kW, int kH)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= width || y >= height) return;

    float3 sum = {0.f, 0.f, 0.f};

    for (int i = 0; i < kW; i++){
        for (int j = 0; j < kH; j++){
            int dX = x + i - kW / 2;
            int dY = y + j - kH / 2;

            dX = max(0, min(dX, width - 1));
            dY = max(0, min(dY, height - 1));

            int matIndex = j + i * kW;
            int idx = (dX + dY * width) * 3;

            sum.x += kernel[matIndex] * in[idx + 0];
            sum.y += kernel[matIndex] * in[idx + 1];
            sum.z += kernel[matIndex] * in[idx + 2];
        }
    }

    int outIdx = (x + y * width) * 3;

    out[outIdx + 0] = (uchar)clampfGPU(sum.x, 0.f, 255.f);
    out[outIdx + 1] = (uchar)clampfGPU(sum.y, 0.f, 255.f);
    out[outIdx + 2] = (uchar)clampfGPU(sum.z, 0.f, 255.f);
}

float convGPU( PPMBitmap &out, const PPMBitmap &in, const float* const kernelConv, int matWidth, int matHeight)
{  

    ChronoGPU chr;
	chr.start();

    size_t imgSize = in.getWidth() * in.getHeight() * 3;

    uchar* pixelIn;
    uchar* pixelOut;
    float* d_kernel; 

    // Allocation de la mémoire sur le GPU
    cudaMalloc(&pixelIn, imgSize); 
    cudaMalloc(&pixelOut, imgSize); 
    cudaMalloc(&d_kernel, matWidth * matHeight * sizeof(float));

    // Copie des données sur le GPU
    cudaMemcpy(pixelIn, in.getPtr(), imgSize, cudaMemcpyHostToDevice);
    cudaMemcpy(pixelOut, out.getPtr(), imgSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_kernel, kernelConv, matWidth * matHeight * sizeof(float), cudaMemcpyHostToDevice);

    // Lancement du kernel
    dim3 block(16,16);
    dim3 grid((in.getWidth() +15)/16, ( in.getHeight()+15)/16);
    kernelComputeGPU<<<grid, block>>>(pixelIn, pixelOut, in.getWidth(), in.getHeight(), d_kernel, matWidth, matHeight);

    // Récupération des données sur le CPU
    cudaMemcpy(out.getPtr(), pixelOut, imgSize, cudaMemcpyDeviceToHost);

    // Libération de la mémoire sur le GPU
    cudaFree(pixelIn);
    cudaFree(pixelOut);
    cudaFree(d_kernel);


    chr.stop();

    return chr.elapsedTime();
}