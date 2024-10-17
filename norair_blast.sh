#!/bin/bash
#SBATCH --ntasks=64
#SBATCH --job-name=norair_blast
#SBATCH --mem=300G                                 # Required RAM - Default memory per CPU is 3GB.
#SBATCH --partition=hugemem-avx2                         # Use smallmem for jobs < 10 GB RAM|Options: hugemen, smallmem, gpu
#SBATCH --mail-user=amulya.baral@nmbu.no            # Email when job is done.
#SBATCH --mail-type=ALL


for contig_file in /mnt/SCRATCH/veom/norwair/all_files/fastp_output/shovill_output/*/spades.fasta; do
    dir_name=$(basename $(dirname $contig_file))
    blastn -query $contig_file -db /mnt/project/PLASTPATH/blast_db/card_blastn -outfmt '6 qseqid sseqid salltitles length pident evalue qlen slen qstart qend sstart send' -num_threads 64 -out /mnt/project/Food_Safety_VET/norair_output/blast_output_card/${dir_name}_blast_output.txt ;
done
    