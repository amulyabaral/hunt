#!/bin/bash
#SBATCH --ntasks=32
#SBATCH --job-name=norair_busco
#SBATCH --mem=200G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

# Create output directory if it doesn't exist
mkdir -p /mnt/project/Food_Safety_VET/norair_output/busco_output

# Create directory for fasta files
mkdir -p /tmp/busco_input

# Find all contig files and copy them with unique names
for spades_dir in /mnt/project/Food_Safety_VET/norair_output/spades_assembly_reference_*; do
    if [ -d "$spades_dir" ]; then
        for contig_file in $(find "$spades_dir" -name "contigs.fasta"); do
            base_name=$(basename $(dirname $(dirname "$contig_file")))
            sample_name=$(basename $(dirname "$contig_file"))
            cp "$contig_file" "/tmp/busco_input/${base_name}_${sample_name}.fasta"
        done
    fi
done

# Run BUSCO on the directory containing all assemblies
busco --in /tmp/busco_input \
    -o "combined_busco" \
    -m genome \
    --out_path "/mnt/project/Food_Safety_VET/norair_output/busco_output" \
    -l pasteurellales_odb12 \
    --cpu 32

# Cleanup
rm -r /tmp/busco_input
