#!/bin/bash

#SBATCH --ntasks=28
#SBATCH --job-name=norair_spades
#SBATCH --mem=120G                                 # Required RAM - Default memory per CPU is 3GB.
#SBATCH --partition=hugemem-avx2                         # Use smallmem for jobs < 10 GB RAM|Options: hugemen, smallmem, gpu
#SBATCH --mail-user=amulya.baral@nmbu.no            # Email when job is done.
#SBATCH --mail-type=ALL

# Base directories
INPUT_DIR="/mnt/SCRATCH/veom/norwair/all_files/fastp_output"
OUTPUT_BASE="/mnt/project/Food_Safety_VET/norair_output"
REGULAR_OUTPUT="${OUTPUT_BASE}/spades_assembly_isolate_output"

# Process each sample
for forward_read in "$INPUT_DIR"/*_1.fq.gz; do
    reverse_read="${forward_read/_1.fq.gz/_2.fq.gz}"
    sample_name="$(basename "$forward_read" _1.fq.gz)"
    echo "Processing sample: $sample_name"
    
    # Create sample-specific output directories
    regular_sample_output="${REGULAR_OUTPUT}/${sample_name}"
    mkdir -p "$regular_sample_output"

    # Perform regular assembly
    spades.py -1 "$forward_read" -2 "$reverse_read" -o "$regular_sample_output" -t 28 --isolate

    echo "Completed processing sample: $sample_name"
    echo "Regular assembly output: $regular_sample_output"
    echo "------------------------------------"
done
echo "All assemblies complete."