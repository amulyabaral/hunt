#!/bin/bash
#SBATCH --job-name=blast_vfdb
#SBATCH --ntasks=32
#SBATCH --mem=300G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

module load blast
module load parallel

BASE_DIR="/mnt/project/Food_Safety_VET/norair_output"
OUTPUT_DIR="${BASE_DIR}/all_blast_output_vfdb"
mkdir -p "$OUTPUT_DIR"

run_blast() {
    input_file="$1"
    dir=$(dirname "$input_file")
    parent=$(basename "$dir")
    grandparent=$(basename "$(dirname "$dir")")
    base_name=$(basename "$input_file" .fasta)
    output_file="${OUTPUT_DIR}/${grandparent}_${parent}_${base_name}_blast_output.tsv"
    
    blastn -query "$input_file" \
           -db /mnt/project/AntibiotiKU/databases/vfdb/vfdb_blast \
           -outfmt '6 qseqid sseqid salltitles length pident evalue qlen slen qstart qend sstart send' \
           > "$output_file"
}

export -f run_blast
export OUTPUT_DIR

find "${BASE_DIR}/spades_assembly_isolate_output" \
     "${BASE_DIR}/spades_assembly_output" \
     "${BASE_DIR}/spades_assembly_reference_output" \
     "${BASE_DIR}/spades_plasmid_output" \
     "${BASE_DIR}/skesa_output" \
     -name "*.fasta" -type f 2>/dev/null | \
     parallel -j $SLURM_NTASKS run_blast {}