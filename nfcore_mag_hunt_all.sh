#!/bin/bash
#SBATCH --ntasks=64
#SBATCH --job-name=nfcore_mag_hunt
#SBATCH --mem=198G
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1             # Reserve one GPU
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

cd /mnt/project/AntibiotiKU/

nextflow run nf-core/mag \
 -profile singularity \
 --input /mnt/project/AntibiotiKU/samples.csv \
 --outdir /mnt/project/AntibiotiKU/hunt_all_nfmag_output \
 -c /mnt/project/AntibiotiKU/nextflow.config \
 --refine_bins_dastool \
 --kraken2_db "/mnt/project/AntibiotiKU/databases/k2_standard_20240904.tar.gz" \
 --run_virus_identification \
 --min_contig_size 1000 \
 --gtdb_db "/mnt/project/AntibiotiKU/gtdb_db/release220" \
 -resume

echo "pipeline complete! yay!"
