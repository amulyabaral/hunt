#!/bin/bash
#SBATCH --ntasks=64                                 # Number of cores (CPU)
#SBATCH --job-name=trim_reads                       # Job name
#SBATCH --mem=300G                                  # Required RAM
#SBATCH --partition=hugemem-avx2                    # Partition
#SBATCH --mail-user=amulya.baral@nmbu.no            # Email when job is done
#SBATCH --mail-type=ALL

module load fastp

# Create output directory if it doesn't exist
mkdir -p /mnt/project/AntibiotiKU/trimmed_reads

# Find the forward reads and process them in parallel using xargs
find /mnt/project/AntibiotiKU/hunt_rawfiles/ -type f -name "*_1.fq.gz" | xargs -P 64 -I {} bash -c '
    forward_read="{}"
    reverse_read="$(echo "$forward_read" | sed "s/_1\.fq\.gz$/_2.fq.gz/")"
    sample_name="$(basename "$forward_read" _1.fq.gz)"
    
    # Define output file names
    trimmed_forward="/mnt/project/AntibiotiKU/trimmed_reads/${sample_name}_trimmed_1.fq.gz"
    trimmed_reverse="/mnt/project/AntibiotiKU/trimmed_reads/${sample_name}_trimmed_2.fq.gz"
    
    # Run fastp for quality trimming
    fastp -i $forward_read -I $reverse_read -o $trimmed_forward -O $trimmed_reverse --thread=1 --detect_adapter_for_pe \
    --html /mnt/project/AntibiotiKU/trimmed_reads/${sample_name}_fastp_report.html
'
