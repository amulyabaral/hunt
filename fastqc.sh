#!/bin/bash

# Define input and output directories
input_dir="/mnt/project/AntibiotiKU/hunt_rawfiles/"
output_dir="/mnt/project/AntibiotiKU/fastqc_output/"

# Number of threads to use
threads=10

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Find and process each .fq.gz file
find "$input_dir" -type f -name "*.fq.gz" | while read -r file; do
    echo "Processing $file with FastQC..."
    fastqc --noextract -t "$threads" -o "$output_dir" "$file"
done

echo "FastQC processing completed."
