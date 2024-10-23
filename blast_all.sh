#!/bin/bash
#SBATCH --job-name=quality_check
#SBATCH --ntasks=64
#SBATCH --mem=300G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

# Load necessary modules
module load blast
module load parallel

# Define base directory and output directory
BASE_DIR="/mnt/project/Food_Safety_VET/norair_output"
OUTPUT_DIR="${BASE_DIR}/all_blast_output"
mkdir -p "$OUTPUT_DIR"

# Function to get parent and grandparent directory names
get_dir_names() {
    local filepath="$1"
    local dir=$(dirname "$filepath")
    local parent=$(basename "$dir")
    local grandparent=$(basename "$(dirname "$dir")")
    echo "${grandparent}_${parent}"
}

# Create a function for the BLAST operation
run_blast() {
    input_file="$1"
    dir_names=$(get_dir_names "$input_file")
    base_name=$(basename "$input_file" .fasta)
    output_file="${OUTPUT_DIR}/${dir_names}_${base_name}_blast.tsv"
    
    blastn -query "$input_file" \
           -db /mnt/project/PLASTPATH/blast_db/card_blastn \
           -outfmt '6 qseqid sseqid salltitles length pident evalue qlen slen qstart qend sstart send' \
           > "$output_file"
    
    echo "Processed: $input_file -> $(basename "$output_file")"
}

# Export the function and variables
export -f run_blast
export -f get_dir_names
export OUTPUT_DIR

# Log start time
echo "Starting BLAST searches at $(date)"

# Find all fasta files from the specific directories and process them in parallel
for dir in "${BASE_DIR}/spades_assembly_isolate_output" \
           "${BASE_DIR}/spades_assembly_output" \
           "${BASE_DIR}/spades_assembly_reference_output" \
           "${BASE_DIR}/spades_plasmid_output" \
           "${BASE_DIR}/skesa_output"; do
    if [ -d "$dir" ]; then
        echo "Processing directory: $dir"
        find "$dir" -name "*.fasta" -type f | \
            parallel --progress -j $SLURM_NTASKS \
            run_blast {}
    fi
done

# Log end time
echo "All BLAST searches completed at $(date)"

# Create a summary
echo "Results saved in: $OUTPUT_DIR"
find "$OUTPUT_DIR" -type f -name "*_blast.tsv" | wc -l > "${OUTPUT_DIR}/summary.txt"
echo "Total files processed: $(cat ${OUTPUT_DIR}/summary.txt)"