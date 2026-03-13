#include <iostream>
#include <string>
#include <iomanip>
#include <cstring>

#include "reference.hpp"

void printUsage() 
{
    std::cerr << "Usage: " << std::endl
              << "\t-f <F> : <F> image file name" << std::endl
              << "\t-m <M> : <M> convolution matrix (bump, sharpen, edge, motion, gaussian)" << std::endl;
    exit(EXIT_FAILURE);
}

int main(int argc, char **argv) 
{
    char fileName[2048];
    std::string matrixName;

    // Parse program arguments
    if (argc == 1) 
    {
        std::cerr << "Please give a file..." << std::endl;
        printUsage();
    }

    for (int i = 1; i < argc; ++i) 
    {
        if (!strcmp(argv[i], "-f")) 
        {
            if (sscanf(argv[++i], "%s", &fileName) != 1)
                printUsage();
        }
        else if (!strcmp(argv[i], "-m"))
        {
            matrixName = argv[++i];
        }
        else
            printUsage();
    }

    // =================================================================
    // Sélection de la matrice de convolution
    const float* matrice = nullptr;
    int matrice_width = 0, matrice_height = 0;

    if (matrixName == "bump") {
        matrice = MAT_BUMP_3x3;
        matrice_width = matrice_height = MAT_BUMP_DIM;
    }
    else if (matrixName == "sharpen") {
        matrice = MAT_SHARPEN_5x5;
        matrice_width = matrice_height = MAT_SHARPEN_DIM;
    }
    else if (matrixName == "edge") {
        matrice = MAT_EDGE_DETECTION_7x7;
        matrice_width = matrice_height = MAT_EDGE_DETECTION_DIM;
    }
    else if (matrixName == "motion") {
        matrice = MAT_MOTION_BLUR_9x9;
        matrice_width = matrice_height = MAT_MOTION_BLUR_DIM;
    }
    else if (matrixName == "gaussian") {
        matrice = MAT_GAUSSIAN_BLUR_11x11;
        matrice_width = matrice_height = MAT_GAUSSIAN_BLUR_DIM;
    }
    else {
        std::cerr << "Unknown matrix: " << matrixName << std::endl;
        printUsage();
    }

    // =================================================================
    // Chargement de l'image
    std::cout << "Loading image: " << fileName << std::endl;
    const PPMBitmap input(fileName);
    const int width = input.getWidth();
    const int height = input.getHeight();

    std::cout << "Image has " << width << " x " << height << " pixels" << std::endl;

    std::string baseSaveName = fileName;
    baseSaveName.erase(baseSaveName.end() - 4, baseSaveName.end()); // erase .ppm

    // Create output image
    PPMBitmap outCPU(width, height);

    // =================================================================
    // CPU sequential
    std::cout << "============================================" << std::endl;
    std::cout << "         Sequential version on CPU          " << std::endl;
    std::cout << "============================================" << std::endl;

    const float timeCPU = convCPU(outCPU, input, matrice, matrice_width, matrice_height);

    std::string cpuName = baseSaveName + "_" + matrixName + "_" + std::to_string(matrice_width) + "x" + std::to_string(matrice_height) +"_cpu"+ ".ppm";
    outCPU.saveTo((cpuName).c_str());

    std::cout << "-> Done : " << timeCPU << " ms" << std::endl << std::endl;



	
	// ================================================================================================================
	// GPU CUDA
	std::cout << "============================================"	<< std::endl;
	std::cout << "         Parallel version on GPU            "	<< std::endl;
	std::cout << "============================================"	<< std::endl;

	const float timeGPU = convGPU( );

	std::string gpuName = baseSaveName + "_" + matrixName + "_" + std::to_string(matrice_width) + "x" + std::to_string(matrice_height) +"_gpu"+ ".ppm";
	outGPU.saveTo(gpuName.c_str());
	
	std::cout << "-> Done : " << timeGPU << " ms" << std::endl << std::endl;
	
	// ================================================================================================================
}