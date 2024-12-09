#!/bin/bash
#SBATCH --ntasks=32
#SBATCH --job-name=norair_quast_busco
#SBATCH --mem=200G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

# Reference genome path
REF_GENOME="/mnt/project/Food_Safety_VET/norair_output/GCF_002073255.2/GCF_002073255.2_ASM207325v2_genomic.fna"

# Create output directories if they don't exist
mkdir -p /mnt/project/Food_Safety_VET/norair_output/quast_output
mkdir -p /mnt/project/Food_Safety_VET/norair_output/busco_output

# Function to process one sample
process_sample() {
    local contig_file=$1
    local base_name=$2
    local sample_name=$3

    # Run QUAST
    quast.py "$contig_file" \
        -r "$REF_GENOME" \
        -o "/mnt/project/Food_Safety_VET/norair_output/quast_output/${base_name}_${sample_name}" \
        --threads 1

    # Run BUSCO
    busco -i "$contig_file" \
        -o "${base_name}_${sample_name}" \
        -m genome \
        --out_path "/mnt/project/Food_Safety_VET/norair_output/busco_output" \
        -l pasteurellales_odb12 \
        -c 1
}

export -f process_sample
export REF_GENOME

# Create a temporary file to store all jobs
tmp_jobs_file=$(mktemp)

# Generate list of all jobs
for spades_dir in /mnt/project/Food_Safety_VET/norair_output/spades_assembly_reference_*; do
    if [ -d "$spades_dir" ]; then
        base_name=$(basename "$spades_dir")
        
        for assembly_dir in "$spades_dir"/*; do
            if [ -d "$assembly_dir" ]; then
                sample_name=$(basename "$assembly_dir")
                contig_file="$assembly_dir/contigs.fasta"
                
                if [ -f "$contig_file" ]; then
                    echo "$contig_file $base_name $sample_name" >> "$tmp_jobs_file"
                fi
            fi
        done
    fi
done

# Run jobs in parallel using xargs
cat "$tmp_jobs_file" | xargs -P 32 -L 1 bash -c 'process_sample $0 $1 $2'

# Clean up
rm "$tmp_jobs_file"
