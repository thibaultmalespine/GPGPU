#include "student.hpp"

#include "utils/chronoGPU.hpp"
#include "utils/commonCUDA.hpp"

__global__ void kernelComputeSepia( const uchar *const dev_inPtr, uchar *const dev_outPtr, const int width, const int height ) 
{		
	// index de la thread 
	int index_x = threadIdx.x + blockDim.x * blockIdx.x;
	int index_y = threadIdx.y + blockDim.y * blockIdx.y;


	for(int x=0; x < width; x++){
		for (int y = 0; y < height; y++){
			
		}
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

	dim3 dimGrid(
		(width  + dimBlock.x - 1) / dimBlock.x,
		(height + dimBlock.y - 1) / dimBlock.y
	);
	
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
