#include "gpu.hpp"

#include "utils/chronoGPU.hpp"
#include "utils/commonCUDA.hpp"


__global__ void kernel(int *data, int *count, uint32_t sampleNb, int N) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx * N < sampleNb) {
        for (int i = idx * N; i < (idx + 1) * N; i++) {
            int value = data[i];
            atomicAdd(&count[value], 1);
        }
    }
}

void gpu_histogramme(int* data, int* count, uint32_t sampleNb, uint32_t distributionSize, int N) {
    
    // allocation mémoire
    int *d_data, *d_count;
    cudaMalloc(&d_data, sampleNb * sizeof(int));
    cudaMalloc(&d_count, distributionSize * sizeof(int));
    
    // copie des données
    cudaMemcpy(d_data, data, sampleNb * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemset(d_count, 0, distributionSize * sizeof(int));
    
    // lancement du kernel
    ChronoGPU chrGPU;
    chrGPU.start();

    int blocSize = 512;
    kernel<<<(((sampleNb/blocSize) + 1) / N)+1, blocSize>>>(d_data, d_count, sampleNb, N);

    chrGPU.stop();
    printf("Temps GPU: %f ms\n", chrGPU.elapsedTime());
    
    // copie du résultat
    cudaMemcpy(count, d_count, distributionSize * sizeof(int), cudaMemcpyDeviceToHost);
    
    // nettoyage
    cudaFree(d_data);
    cudaFree(d_count);
}