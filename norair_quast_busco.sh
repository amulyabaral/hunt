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

# Run BUSCO on all assemblies at once
while read contig_file; do
    base_name=$(basename $(dirname $(dirname "$contig_file")))
    sample_name=$(basename $(dirname "$contig_file"))
    ln -s "$contig_file" "/tmp/${base_name}_${sample_name}.fasta"
done < "$tmp_contig_list"

busco --in /tmp/*.fasta \
    -o "combined_busco" \
    -m genome \
    --out_path "/mnt/project/Food_Safety_VET/norair_output/busco_output" \
    -l pasteurellales_odb12 \
    --cpu 32

# Cleanup
rm "$tmp_contig_list"
rm /tmp/*.fasta
