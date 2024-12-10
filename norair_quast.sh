#!/bin/bash
#SBATCH --ntasks=32
#SBATCH --job-name=norair_quast
#SBATCH --mem=200G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

# Reference genome path
REF_GENOME="/mnt/project/Food_Safety_VET/norair_output/GCF_002073255.2/GCF_002073255.2_ASM207325v2_genomic.fna"

# Create output directory if it doesn't exist
mkdir -p /mnt/project/Food_Safety_VET/norair_output/quast_output

# Create temporary file to store all contig paths
tmp_contig_list=$(mktemp)

# Find all contig files and save their paths
for spades_dir in /mnt/project/Food_Safety_VET/norair_output/spades_assembly_reference_*; do
    if [ -d "$spades_dir" ]; then
        find "$spades_dir" -name "contigs.fasta" >> "$tmp_contig_list"
    fi
done

# Run QUAST on all assemblies at once
quast.py --threads 32 \
    -r "$REF_GENOME" \
    -o "/mnt/project/Food_Safety_VET/norair_output/quast_output/combined_quast" \
    $(cat "$tmp_contig_list")

# Cleanup
rm "$tmp_contig_list"
