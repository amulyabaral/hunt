#!/bin/bash
#SBATCH --ntasks=50
#SBATCH --job-name=megahit_benchmark
#SBATCH --mem=100G
#SBATCH --partition=hugemem-avx2
#SBATCH --mail-user=amulya.baral@nmbu.no
#SBATCH --mail-type=ALL

Directories
INPUT_DIR="/mnt/project/AntibiotiKU/trimmed_reads"
OUTPUT_DIR="/mnt/project/AntibiotiKU/megahit_benchmark"
SUBSAMPLE_DIR="${OUTPUT_DIR}/subsampled"
mkdir -p "${OUTPUT_DIR}" "${SUBSAMPLE_DIR}"

Configuration
CPU_COUNTS=(1 4 8 16 32 50)    # CPU counts for different runs
SUBSAMPLE_RATE=0.05           # Initial subsampling rate

Function for subsampling paired-end files
subsample() {
local sample=$1
local read=$2  # "1" or "2"
seqtk sample -s 42 "${INPUT_DIR}/${sample}trimmed${read}.fq.gz" "${SUBSAMPLE_RATE}" | gzip > "${SUBSAMPLE_DIR}/${sample}_${read}.fq.gz"
}

Select 5 random samples
mapfile -t samples < <(find "${INPUT_DIR}" -name "_trimmed_1.fq.gz" -exec basename {} _trimmed_1.fq.gz ; | shuf -n 5)
echo "Selected samples: ${samples[]}"

Calibrate subsampling rate using the first sample with max CPUs (50)
sample0="${samples[0]}"
subsample "${sample0}" "1"
subsample "${sample0}" "2"
start_time=$(date +%s)
megahit -1 "${SUBSAMPLE_DIR}/${sample0}_1.fq.gz" -2 "${SUBSAMPLE_DIR}/${sample0}_2.fq.gz" 

-o "${OUTPUT_DIR}/test_run" --num-cpu-threads 50 --min-contig-len 500 > /dev/null
duration=$(( $(date +%s) - start_time ))
rm -rf "${OUTPUT_DIR}/test_run"

if [[ ${duration} -lt 180 || ${duration} -gt 300 ]]; then
SUBSAMPLE_RATE=$(echo "scale=3; ${SUBSAMPLE_RATE} * 240 / ${duration}" | bc)
echo "Adjusted subsample rate to ${SUBSAMPLE_RATE} (previous duration: ${duration} s)"
fi

Create subsampled files for all samples
for sample in "${samples[@]}"; do
echo "Subsampling ${sample}..."
subsample "${sample}" "1"
subsample "${sample}" "2"
done

Initialize results file
RESULTS_CSV="${OUTPUT_DIR}/results.csv"
echo "sample,cpus,time_seconds" > "${RESULTS_CSV}"

Run benchmarks with different CPU counts for each sample
for sample in "${samples[@]}"; do
echo "Benchmarking sample: ${sample}"
for cpu in "${CPU_COUNTS[@]}"; do
out_dir="${OUTPUT_DIR}/${sample}_cpu${cpu}"
rm -rf "${out_dir}"
start_time=$(date +%s)
megahit -1 "${SUBSAMPLE_DIR}/${sample}_1.fq.gz" -2 "${SUBSAMPLE_DIR}/${sample}_2.fq.gz" 

-o "${out_dir}" --num-cpu-threads "${cpu}" --min-contig-len 500 > /dev/null
duration=$(( $(date +%s) - start_time ))
echo "${sample},${cpu},${duration}" >> "${RESULTS_CSV}"
echo "  ${cpu} CPUs: ${duration}s"
done
done

Generate summary report
summary="${OUTPUT_DIR}/summary.txt"
{
echo "MEGAHIT CPU Scaling Benchmark"
echo "Subsampling rate: ${SUBSAMPLE_RATE}"
echo -e "\nAssembly Times (seconds):"
printf "%-20s" "Sample"
for cpu in "${CPU_COUNTS[@]}"; do
printf "| %-10s " "${cpu} CPUs"
done
echo ""

code

for sample in "${samples[@]}"; do
    printf "%-20s" "${sample}"
    for cpu in "${CPU_COUNTS[@]}"; do
        time=$(grep "^${sample},${cpu}," "${RESULTS_CSV}" | cut -d',' -f3)
        printf "| %-10s " "${time}s"
    done
    echo ""
done

echo -e "\nSpeedup Analysis (relative to 4 CPUs):"
printf "%-20s" "Sample"
for cpu in "${CPU_COUNTS[@]:1}"; do
    printf "| %-10s " "${cpu} CPUs"
done
echo ""

for sample in "${samples[@]}"; do
    printf "%-20s" "${sample}"
    base_time=$(grep "^${sample},4," "${RESULTS_CSV}" | cut -d',' -f3)
    for cpu in "${CPU_COUNTS[@]:1}"; do
        time=$(grep "^${sample},${cpu}," "${RESULTS_CSV}" | cut -d',' -f3)
        speedup=$(echo "scale=2; ${base_time} / ${time}" | bc)
        # Efficiency calculated relative to 4 CPUs
        efficiency=$(echo "scale=0; 100 * ${speedup} / (${cpu} / 4)" | bc)
        printf "| %-10s " "${speedup}x (${efficiency}%)"
    done
    echo ""
done

echo -e "\nNOTE: Efficiency percentage shows scaling relative to 4 CPUs (100% = perfect scaling)."
} > "${summary}"

echo "Benchmark complete. Summary available at ${summary}"