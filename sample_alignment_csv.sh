#!/bin/bash
cd /mnt/project/AntibiotiKU/hunt_host_removed
# Create new csv file and write the headers
echo "sample,cow,pig,dog" > alignment_rates.csv

# For each .log file in the directory
for file in *.log; do
  # Extract the sample name
  sample=$(echo $file | cut -d'.' -f1)

  # Initialize variables for cow, pig, and dog
  cow="N/A"
  pig="N/A"
  dog="N/A"

  # Check the species and extract the alignment rate
  case $(echo $file | cut -d'.' -f2) in
    cow) cow=$(grep 'overall alignment rate' $file | awk '{print $1}') ;;
    pig) pig=$(grep 'overall alignment rate' $file | awk '{print $1}') ;;
    dog) dog=$(grep 'overall alignment rate' $file | awk '{print $1}') ;;
  esac

  # Write the data to the csv file
  echo "$sample,$cow,$pig,$dog" >> alignment_rates.csv
done