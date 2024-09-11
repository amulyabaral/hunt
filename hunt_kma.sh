#!/bin/bash
#SBATCH --ntasks=64
#SBATCH --job-name=kma_hunt 
#SBATCH --mem=300G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

# cd $PROJECTS/AntibiotiKU
find "/mnt/project/AntibiotiKU/hunt_host_removed" -type f -name "*.fq.1.gz" > forward_reads.txt

# Iterate through the forward read files
for forward_read in $(cat forward_reads.txt); do
    reverse_read="${forward_read/.fq.1.gz/.fq.2.gz}"
    sample_name="$(basename "$forward_read" .fq.1.gz)"
    echo -e "Now processing \n Forward read: $forward_read \n Reverse read: $reverse_read \nSample name: $sample_name"
    
    kma -ipe $forward_read $reverse_read -ef -1t1 -cge -nf -vcf -t 64 \
    -o /mnt/project/AntibiotiKU/kma_output_hunt/${sample_name}_output \
    -t_db /mnt/project/AntibiotiKU/databases/kma_db/megares_database_v3.00
done

