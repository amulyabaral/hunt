#!/bin/bash
#SBATCH --ntasks=64
#SBATCH --job-name=nfcore_mag_hunt
#SBATCH --mem=198
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1             # Reserve one GPU
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

cd /mnt/project/AntibiotiKU/

nextflow run nf-core/mag \
        -profile singularity \
        --input /mnt/project/AntibiotiKU/samples.csv \
        --output /mnt/project/AntibiotiKU/hunt_all_nfmag_output \
        -c /mnt/project/AntibiotiKU/nextflow.config \
        --max_cpus 64 \
        --max_memory 198.GB \
        --refine_bins_dastool \
        --kraken2_db /mnt/project/AntibiotiKU/databases/k2_standard_20231009 \
        --run_virus_identification \
        --min_contig_size 1000 \


echo "pipeline complete! yay!"
