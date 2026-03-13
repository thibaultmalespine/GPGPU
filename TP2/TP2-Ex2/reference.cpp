#include "reference.hpp"

float clampf(float n, float lower, float upper)
{
  return std::max<float>(lower, std::min<float>(n, upper));
}

float convCPU(PPMBitmap &out, const PPMBitmap &in, const float *const kernelConv, int matWidth, int matHeight)
{
    int imgWidth = in.getWidth();
    int imgHeight = in.getHeight();

    ChronoCPU chr;
	chr.start();

    for (int x = 0; x < imgWidth; ++x){
        for (int y=0;y < imgHeight; ++y){
            RGBcol pixelOut;
            float3 sum = {0.f};
            for (int i=0; i < matWidth; i++){
                for (int j=0; j < matHeight; j++){
					int dX = x + i - matWidth / 2;
					int dY = y + j - matHeight / 2;

					if ( dX < 0 ) 
						dX = 0;

					if ( dX >= imgWidth ) 
						dX = imgWidth - 1;

					if ( dY < 0 ) 
						dY = 0;

					if ( dY >= imgHeight ) 
						dY = imgHeight - 1;

					int matIndex = j + i*matWidth;

                    const RGBcol &pixelIn = in.getPixel( dX, dY );
                    sum.x += (float) (kernelConv[matIndex] * pixelIn._r);
                    sum.y += (float) (kernelConv[matIndex] * pixelIn._g);
                    sum.z += (float) (kernelConv[matIndex] * pixelIn._b);
                }
            }

            pixelOut._r = (unsigned char) clampf(sum.x,0.f,255.f);
            pixelOut._g = (unsigned char) clampf(sum.y,0.f,255.f);
            pixelOut._b = (unsigned char) clampf(sum.z,0.f,255.f);

            out.setPixel(x,y,pixelOut);
        }
    }
    chr.stop();

    return chr.elapsedTime();
}

