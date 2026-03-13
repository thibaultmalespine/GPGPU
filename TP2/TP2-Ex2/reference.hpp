#ifndef __REFERENCE_HPP__
#define __REFERENCE_HPP__

#include "utils/commonCUDA.hpp"
#include "convMatrices.hpp"
#include "utils/ppm.hpp"
#include "utils/chronoCPU.hpp"

float convCPU( PPMBitmap &out, const PPMBitmap &in, const float *const kernelConv, int matWidth, int matHeight);

#endif