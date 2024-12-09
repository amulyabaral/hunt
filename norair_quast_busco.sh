#!/bin/bash
#SBATCH --ntasks=64
#SBATCH --job-name=norair_quast_busco
#SBATCH --mem=300G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

# Reference genome path
REF_GENOME="/mnt/project/Food_Safety_VET/norair_output/GCF_002073255.2/GCF_002073255.2_ASM207325v2_genomic.fna"

# Create output directories if they don't exist
mkdir -p /mnt/project/Food_Safety_VET/norair_output/quast_output
mkdir -p /mnt/project/Food_Safety_VET/norair_output/busco_output

# Loop through all spades_ directories
for spades_dir in /mnt/project/Food_Safety_VET/norair_output/spades_*; do
    if [ -d "$spades_dir" ]; then
        # Loop through each assembly folder
        for assembly_dir in "$spades_dir"/*; do
            if [ -d "$assembly_dir" ]; then
                sample_name=$(basename "$assembly_dir")
                contig_file="$assembly_dir/contigs.fasta"
                
                if [ -f "$contig_file" ]; then
                    # Run QUAST
                    quast.py "$contig_file" \
                        -r "$REF_GENOME" \
                        -o "/mnt/project/Food_Safety_VET/norair_output/quast_output/${sample_name}" \
                        --threads 64
                    
                    # Run BUSCO
                    busco -i "$contig_file" \
                        -o "${sample_name}" \
                        -m genome \
                        --out_path "/mnt/project/Food_Safety_VET/norair_output/busco_output" \
                        -l bacteria_odb10 \
                        -c 64
                fi
            fi
        done
    fi
done
