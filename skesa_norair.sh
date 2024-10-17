#!/bin/bash
#SBATCH --ntasks=64
#SBATCH --job-name=norair_blast
#SBATCH --mem=300G                                 # Required RAM - Default memory per CPU is 3GB.
#SBATCH --partition=hugemem-avx2                         # Use smallmem for jobs < 10 GB RAM|Options: hugemen, smallmem, gpu
#SBATCH --mail-user=amulya.baral@nmbu.no            # Email when job is done.
#SBATCH --mail-type=ALL

find "/mnt/SCRATCH/veom/norwair/all_files/fastp_output" -type f -name "*_1.fq.gz" > forward_reads_norair.txt

# Iterate through the forward read files
for forward_read in $(cat forward_reads_norair.txt); do
    reverse_read="${forward_read/_1.fq.gz/_2.fq.gz}"
    sample_name="$(basename "$forward_read" _1.fq.gz)"
    echo -e "Now processing \n Forward read: $forward_read \n Reverse read: $reverse_read \nSample name: $sample_name"
    
    skesa --reads $forward_read,$reverse_read \
        -- cores 64 \
        --memory 280 \
        > /mnt/project/Food_Safety_VET/norair_output/skesa_output/$sample_name.skesa.fa

done