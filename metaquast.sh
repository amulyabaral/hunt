#!/bin/bash
#SBATCH --job-name=hunt_metaquast
#SBATCH --ntasks=32
#SBATCH --mem=300G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

PARENT_DIR="/mnt/project/AntibiotiKU/megahit_assemblies"
OUT_DIR="${PARENT_DIR}/metaquast_results"
THREADS=32

# Create output directory
mkdir -p "$OUT_DIR"

# Find all final.contigs.fa files within the immediate subdirectories
mapfile -t CONTIG_FILES < <(find "$PARENT_DIR" -mindepth 2 -maxdepth 2 -type f -name "final.contigs.fa")

# Run metaquast.py
# -o: specifies output directory
# -L: uses parent directory names as labels for assemblies
# -t: specifies number of threads
# "${CONTIG_FILES[@]}": passes the list of found contig files
metaquast.py \
    -o "$OUT_DIR" \
    -L \
    -t "$THREADS" \
    -f \
    --rna-finding \
    -k \
    --max-ref-number 0 \
    --report-all-metrics \
    "${CONTIG_FILES[@]}"

echo "MetaQUAST finished. Results: $OUT_DIR"

