#!/bin/bash
#SBATCH --ntasks=64                                 # Number of cores (CPU)
#SBATCH --nodes=1                                   # Number of nodes to use
#SBATCH --job-name=hunt_host                        # Job name 
#SBATCH --mem=300G                                  # Required RAM - Default memory per CPU is 3GB.
#SBATCH --partition=hugemem-avx2                    # Use smallmem for jobs < 10 GB RAM|Options: hugemen, smallmem, gpu
#SBATCH --mail-user=amulya.baral@nmbu.no            # Email when job is done.
#SBATCH --mail-type=ALL

module load Bowtie2

# Find the forward reads and process them in parallel using xargs
find /mnt/project/AntibiotiKU/hunt_rawfiles/ -type f -name "*_1.fq.gz" | xargs -P 64 -I {} bash -c '
    forward_read="{}"
    reverse_read="$(echo "$forward_read" | sed "s/_1\.fq\.gz$/_2.fq.gz/")"
    sample_name="$(basename "$forward_read" _1.fq.gz)"
    # Run Bowtie2 and only output the summary
    bowtie2 -x /mnt/project/AntibiotiKU/bowtie_indexes/canfam4/canfam4 -p 1 -1 $forward_read -2 $reverse_read \
    --no-unal --no-head > /dev/null 2> /mnt/project/AntibiotiKU/hunt_host_removed/$sample_name.dog.bowtie2.log
'
