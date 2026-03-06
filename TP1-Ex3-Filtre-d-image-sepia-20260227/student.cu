#include "student.hpp"

#include "utils/chronoGPU.hpp"
#include "utils/commonCUDA.hpp"
__global__ void kernelComputeSepia(const uchar* in, uchar* out,
                                   int width, int height)
{
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    int n = width * height;

    for (int p = tid; p < n; p += stride)
    {
        int i = p * 3;

        uchar r = in[i];
        uchar g = in[i+1];
        uchar b = in[i+2];

        out[i]   = fminf(255.f, r*0.393f + g*0.769f + b*0.189f);
        out[i+1] = fminf(255.f, r*0.349f + g*0.686f + b*0.168f);
        out[i+2] = fminf(255.f, r*0.272f + g*0.534f + b*0.131f);
    }
}

float sepiaGPU( const PPMBitmap &in, PPMBitmap &out ) 
{
	// Pixel table on Host
	uchar *inPtr	= in.getPtr();
	uchar *outPtr	= out.getPtr();

	// Pixel table on Device
	uchar *dev_inPtr;
	uchar *dev_outPtr;

	const size_t sizeImg = in.getSize();

	const int width		= in.getWidth();
	const int height	= in.getHeight();


	/// Allocate memory on Device
	HANDLE_ERROR(cudaMalloc(&dev_inPtr, sizeImg));
	HANDLE_ERROR(cudaMalloc(&dev_outPtr,sizeImg));

	/// Copy from Host to Device
	HANDLE_ERROR(cudaMemcpy(dev_inPtr, inPtr, sizeImg, cudaMemcpyHostToDevice));

	/// Configure kernel
	dim3 dimBlock(12, 12);

	dim3 dimGrid(12, 12);
	
	ChronoGPU chr;
	chr.start();
	
	/// Launch kernel
	kernelComputeSepia<<<dimGrid, dimBlock>>>(dev_inPtr, dev_outPtr, width, height);

	// Copy from Device to Host
	HANDLE_ERROR(cudaMemcpy(outPtr, dev_outPtr, sizeImg, cudaMemcpyDeviceToHost));


	chr.stop();

	/// Free memory on Device
	HANDLE_ERROR(cudaFree(dev_inPtr));
	HANDLE_ERROR(cudaFree(dev_outPtr));

	return chr.elapsedTime();
}
