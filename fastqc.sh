#!/bin/bash
#SBATCH --job-name=quality_check
#SBATCH --ntasks=16
#SBATCH --mem=80G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL


# input and output directories
input_dir="/mnt/project/AntibiotiKU/hunt_rawfiles/"
output_dir="/mnt/project/AntibiotiKU/fastqc_output/"

# number of threads to use
threads=32

# creating the output directory if it doesn't exist
mkdir -p "$output_dir"


find "$input_dir" -type f -name "*.fq.gz" | while read -r file; do
    echo "Processing $file with FastQC..."
    fastqc --noextract -t "$threads" -o "$output_dir" "$file"
done

echo "FastQC processing completed."
