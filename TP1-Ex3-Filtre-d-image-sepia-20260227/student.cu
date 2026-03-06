#include "student.hpp"

#include "utils/chronoGPU.hpp"

void kernelComputeSepia( const uchar *const dev_inPtr, uchar *const dev_outPtr, const int width, const int height ) 
{		
	int i = threadIdx.x + threadIdx.y * blockDim.x + blockIdx.x * blockDim.x * blockDim.y + blockIdx.y * gridDim.x * blockDim.x * blockDim.y;

	if (i < width * height){
		// Code du kernel
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


	/// TODO - Allocate memory on Device
	cudaMalloc(&dev_inPtr, sizeof(unsigned char));
	cudaMalloc(&dev_inPtr, sizeof(unsigned char));

	/// TODO - Copy from Host to Device
	cudaMemcpy(dev_inPtr, inPtr, sizeof(unsigned char), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_outPtr, outPtr, sizeof(unsigned char), cudaMemcpyHostToDevice);

	/// TODO - Configure kernel
	dim3 dimBlock(12, 12);

	dim3 dimGrid(
		(width  + dimBlock.x - 1) / dimBlock.x,
		(height + dimBlock.y - 1) / dimBlock.y
	);
	
	ChronoGPU chr;
	chr.start();
	
	/// TODO - Launch kernel
	kernelComputeSepia<<<dimGrid, dimBlock>>>(dev_inPtr, dev_outPtr, width, height);

	chr.stop();

	/// TODO - Free memory on Device
	cudaFree(dev_inPtr);
	cudaFree(dev_outPtr);

	return chr.elapsedTime();
}
