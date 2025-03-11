#!/bin/bash
#SBATCH --ntasks=150
#SBATCH --job-name=hunt_assemble 
#SBATCH --mem=300G 
#SBATCH --partition=hugemem-avx2 
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL
#!/bin/bash

# Define directories
INPUT_DIR="/mnt/project/AntibiotiKU/trimmed_reads"
OUTPUT_DIR="/mnt/project/AntibiotiKU/megahit_assemblies"

# Create output directory
mkdir -p ${OUTPUT_DIR}

# Function to run MEGAHIT
run_megahit() {
    sample=$1
    megahit -1 ${INPUT_DIR}/${sample}_trimmed_1.fq.gz -2 ${INPUT_DIR}/${sample}_trimmed_2.fq.gz \
        -o ${OUTPUT_DIR}/${sample} \
        --num-cpu-threads 50 \
        --min-contig-len 500
}

# Export function for xargs
export -f run_megahit
export INPUT_DIR OUTPUT_DIR

# Find all samples and run MEGAHIT in parallel
find ${INPUT_DIR} -name "*_trimmed_1.fq.gz" | \
    sed "s|${INPUT_DIR}/||" | \
    sed "s|_trimmed_1.fq.gz||" | \
    xargs -P 3 -I{} bash -c 'run_megahit {}'
