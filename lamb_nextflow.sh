#!/bin/bash
#SBATCH --job-name=lamb_microbiome
#SBATCH --ntasks=64
#SBATCH --mem=100G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

# commands above are sets of introductions to use resources from the cluster
#i am asking for 64 cpus and 300 GB of RAM from hugemem nodes

# run this after activating the nextflow environment 
# https://nf-co.re/ampliseq/2.6.1/docs/usage/#table-of-contents 
# read this for documentation for pipeline 

echo "nextflow started"

nextflow run nf-core/ampliseq \
        -profile singularity \
        --outdir "/mnt/project/Food_Safety_VET/lamb/ampliseq_output" \
        --input "/mnt/project/Food_Safety_VET/lamb/Noyes_Project_069_ReSeq/samples.tsv" \
        --FW_primer GACTCCTACGGGAGGCWGCAG \
        --RV_primer GGACTACHVGGGTWTCTAAT \
        -c /mnt/project/AntibiotiKU/nextflow.config
echo "pipeline completed!"