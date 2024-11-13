#!/bin/bash
#SBATCH --ntasks=128                                 # Number of cores (CPU)
#SBATCH --job-name=hunt_kraken                       # Job name 
#SBATCH --mem=300G                                  # Required RAM - Default memory per CPU is 3GB.
#SBATCH --partition=hugemem-avx2                    # Use smallmem for jobs < 10 GB RAM|Options: hugemen, smallmem, gpu
#SBATCH --mail-user=amulya.baral@nmbu.no            # Email when job is done.
#SBATCH --mail-type=ALL

# Find the forward reads and process them in parallel using xargs
find /mnt/project/AntibiotiKU/trimmed_reads/ -type f -name "*_1.fq.gz" | xargs -P 2 -I {} bash -c '
    forward_read="{}"
    reverse_read="$(echo "$forward_read" | sed "s/_1\.fq\.gz$/_2.fq.gz/")"
    sample_name="$(basename "$forward_read" _1.fq.gz)"
    kraken2 --threads 64 --gzip-compressed --db /mnt/project/AntibiotiKU/databases/k2_standard_20231009 --paired $forward_read $reverse_read --output /mnt/project/AntibiotiKU/hunt_kraken2_output/$sample_name.kraken_out --report /mnt/project/AntibiotiKU/hunt_kraken2_output/$sample_name.kraken_report.txt
'



