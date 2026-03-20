#include <cstdint>

#include "utils/chronoCPU.hpp"
#include "generator.hpp"
#include "gpu.hpp"

int main(int argc, char* argv[])
{
    /* Vérification des arguments */
    if (argc < 2) {
        fprintf(stderr, "Erreur : parametre N manquant. Usage : %s <N>\n", argv[0]);
        fprintf(stderr, "  N = nombre d'elements par thread pour le kernel GPU\n");
        return 1;
    }

    int N = atoi(argv[1]);
    if (N <= 0) {
        fprintf(stderr, "Erreur : parametre N invalide ('%s'). N doit etre un entier positif.\n", argv[1]);
        return 1;
    }


    /* Génération de données aléatoires */
    hst::Generator generator;
    const uint32_t sampleNb = 100000000;
    const uint32_t distributionSize = 128;
    int *data = new int[sampleNb];
    
    generator.sample(sampleNb, distributionSize, data);
    

    /* Version CPU */
    ChronoCPU chr;
	chr.start();

    int *cpuCount = new int[distributionSize]();
    for (uint32_t i = 0; i < sampleNb; i++) {
        cpuCount[data[i]]++;
    }

    chr.stop();
    printf("Temps CPU: %f ms\n", chr.elapsedTime());


    /* Version GPU */
    int *gpuCount = new int[distributionSize]();
    gpu_histogramme(data, gpuCount, sampleNb, distributionSize, N);


    /* Vérification GPU vs CPU */
    bool ok = true;
    uint32_t errors = 0;
    for (uint32_t i = 0; i < distributionSize; i++) {
        if (cpuCount[i] != gpuCount[i]) {
            if (errors < 10) {
                printf("Discrepance à %u : CPU=%d, GPU=%d\n", i, cpuCount[i], gpuCount[i]);
            }
            ok = false;
            errors++;
        }
    }
    if (ok) {
        printf("Validation: CPU et GPU sont identiques (%u bins)\n", distributionSize);
    } else {
        printf("Validation: %u discrepances trouvees sur %u bins\n", errors, distributionSize);
    }

    /* Libération de la mémoire */
    delete[] data;
    delete[] cpuCount;
    delete[] gpuCount;

    return 0;
}