#include "gpu.hpp"

#include "utils/chronoGPU.hpp"
#include "utils/commonCUDA.hpp"


__global__ void kernel(int *data, int *count, uint32_t sampleNb, int N) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < sampleNb) {
        for (int i = (idx - 1) * N; i < idx * N; i++) {
            int value = data[i];
            atomicAdd(&count[value], 1);
        }
    }
}

void gpu_histogramme(int* data, int* count, uint32_t sampleNb, uint32_t distributionSize, int N) {
    ChronoGPU chrGPU;
    chrGPU.start();

    // allocation mémoire
    int *d_data, *d_count;
    cudaMalloc(&d_data, sampleNb * sizeof(int));
    cudaMalloc(&d_count, distributionSize * sizeof(int));

    // copie des données
    cudaMemcpy(d_data, data, sampleNb * sizeof(int), cudaMemcpyHostToDevice);
    
    // lancement du kernel
    kernel<<<((distributionSize/512) + 1) / N, 512>>>(d_data, d_count, sampleNb, N);

    // copie du résultat
    cudaMemcpy(count, d_count, distributionSize * sizeof(int), cudaMemcpyDeviceToHost);

    chrGPU.stop();
    printf("Temps GPU: %f ms\n", chrGPU.elapsedTime());
    
    // nettoyage
    cudaFree(d_data);
    cudaFree(d_count);
}