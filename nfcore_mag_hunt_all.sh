#!/bin/bash
#SBATCH --ntasks=64
#SBATCH --job-name=nfcore_mag_hunt
#SBATCH --mem=300G
#SBATCH --partition=hugemem-avx2
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
 --min_contig_size 1500 \
 --skip_gtdbtk \
 -resume

echo "pipeline complete! yay!"
