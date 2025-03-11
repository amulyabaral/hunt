#!/bin/bash
#SBATCH --ntasks=64                              # Number of cores (CPU)
#SBATCH --job-name=hunt_host                     # Job name
#SBATCH --mem=300G                               # Required RAM - Default memory per CPU is 3GB.
#SBATCH --mail-user=amulya.baral@nmbu.no         # Email when job is done.
#SBATCH --mail-type=ALL

module load Bowtie2

# Function to process each sample
process_sample() {
    forward_read=$1
    reverse_read=$(echo "$forward_read" | sed 's/_1\.fq\.gz$/_2.fq.gz/')
    sample_name=$(basename "$forward_read" _1.fq.gz)
    echo "Processing $sample_name"
    bowtie2 -x /mnt/project/AntibiotiKU/bowtie_indexes/ARS-UCD1.2/ARS-UCD1.2 -p 8 -1 $forward_read -2 $reverse_read --un-conc-gz /mnt/project/AntibiotiKU/hunt_host_removed_trimmed/$sample_name.host_removed.fq.gz > /mnt/project/AntibiotiKU/hunt_host_removed_trimmed/$sample_name.mapped_unmapped.sam
}

export -f process_sample

# Find all forward reads and pass them to xargs
find /mnt/project/AntibiotiKU/trimmed_reads/ -type f -name "*_1.fq.gz" | xargs -n 1 -P 8 -I {} bash -c 'process_sample "$@"' _ {}
