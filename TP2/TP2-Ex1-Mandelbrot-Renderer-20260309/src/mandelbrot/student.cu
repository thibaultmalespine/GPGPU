#include "mdbr/cuda/color.cuh"
#include "mdbr/mandelbrot/student.hpp"

namespace mdbr
{
	__device__ float MandelbrotGPU( const DeviceComplex & c, const int maxIteration )
	{
		DeviceComplex z = c;
		uint32_t	  n = 0;
		for ( ; n < maxIteration; ++n )
		{
			if ( cuda::std::abs( z ) >= 2.f )
				break;
			z = ( z * z ) + c;
		}
		return static_cast<float>( n ) / static_cast<float>( maxIteration );
	}

	__global__ void renderMandelbrotGPU( MandelbrotConfiguration configuration, uchar4 * const pixels )
	{

		int x = blockIdx.x * blockDim.x + threadIdx.x;
		int y = blockIdx.y * blockDim.y + threadIdx.y;

		if (x >= configuration.width || y >= configuration.height)
			return;

		int stride_x = blockDim.x * gridDim.x;
		int stride_y = blockDim.y * gridDim.y;

		const DeviceComplex center( -.7f + configuration.shiftX, configuration.shiftY );
		const DeviceComplex span( 2.7f / configuration.zoom,
							-( 4.f / 3.f ) * 2.7f * configuration.height / configuration.width / configuration.zoom );
		const DeviceComplex begin( center - ( span / 2.f ) );
		const DeviceComplex end( center + ( span / 2.f ) );

		for ( ; x < configuration.width; x += stride_x)
		{
			for ( ; y < configuration.height; y += stride_y )
			{
				const DeviceComplex c = begin
								  + DeviceComplex( x / configuration.zoom * span.real() / ( configuration.width + 1.f ),
											 y / configuration.zoom * span.imag() / ( configuration.height + 1.f ) );
				const float res = MandelbrotGPU( c, configuration.maxIteration );

				const int idPixel = x + y * configuration.width;

				if ( res >= 1.f )
				{
					pixels[ idPixel ].x = 0;
					pixels[ idPixel ].y = 0;
					pixels[ idPixel ].z = 0;
					pixels[ idPixel ].w = 255;
				}
				else
				{
					const float res2
						= logf( 1.f + res * configuration.maxIteration ) / logf( 1.f + configuration.maxIteration );
					const uchar3 rgb	= floatToRGB( res2 );
					pixels[ idPixel ].x = rgb.x;
					pixels[ idPixel ].y = rgb.y;
					pixels[ idPixel ].z = rgb.z;
					pixels[ idPixel ].w = 255;
				}
			}
		}

	}
} // namespace mdbr
