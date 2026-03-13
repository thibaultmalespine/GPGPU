#ifndef __STUDENT_HPP__
#define __STUDENT_HPP__

#include "utils/ppm.hpp"
#include "utils/commonCUDA.hpp"

__global__ void kernelComputeGpu( );
float convGPU( PPMBitmap &out, const PPMBitmap &in, const float *const kernelConv, int matWidth, int matHeight );

#endif // __STUDENT_HPP__
