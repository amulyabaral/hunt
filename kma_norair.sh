#!/bin/bash
#SBATCH --ntasks=64
#SBATCH --job-name=kma_norair
#SBATCH --mem=160G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

# cd $PROJECTS/AntibiotiKU
find "/mnt/SCRATCH/veom/norwair/all_files/fastp_output" -type f -name "*_1.fq.gz" > forward_reads_norair.txt

# Iterate through the forward read files
for forward_read in $(cat forward_reads_norair.txt); do
    reverse_read="${forward_read/_1.fq.gz/_2.fq.gz}"
    sample_name="$(basename "$forward_read" _1.fq.gz)"
    echo -e "Now processing \n Forward read: $forward_read \n Reverse read: $reverse_read \nSample name: $sample_name"
    
    kma -ipe $forward_read $reverse_read -ef -1t1 -cge -nf -vcf -t 64 \
    -o /mnt/project/Food_Safety_VET/norair_output/kma_output_megares/${sample_name}_kma_output \
    -t_db /mnt/project/AntibiotiKU/databases/kma_db/megares_database_v3.00
done

