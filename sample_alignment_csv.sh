#!/bin/bash

cd /mnt/project/AntibiotiKU/hunt_host_removed

# Create new csv file and write the headers
echo "sample,cow,pig,dog" > alignment_rates.csv

# Create associative arrays to hold alignment rates
declare -A cow_rates pig_rates dog_rates

# For each .log file in the directory
for file in *.log; do
    # Extract the sample name
    sample=$(echo $file | cut -d'.' -f1)

    # Extract the alignment rate
    rate=$(grep 'overall alignment rate' $file | awk '{print $1}')

    # Check the species and add the alignment rate to the correct array
    case $(echo $file | cut -d'.' -f2) in
        cow) cow_rates["$sample"]=$rate ;;
        pig) pig_rates["$sample"]=$rate ;;
        dog) dog_rates["$sample"]=$rate ;;
    esac
done

# Write the data to the csv file
for sample in "${!cow_rates[@]}"; do
    echo "$sample,${cow_rates["$sample"]}, ${pig_rates["$sample"]}, ${dog_rates["$sample"]}" >> alignment_rates.csv
done