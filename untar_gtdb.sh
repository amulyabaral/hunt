#!/bin/bash
#SBATCH --ntasks=32                                 # Number of cores (CPU)
#SBATCH --job-name=quick_tar                       # Job name
#SBATCH --mem=128                                  # Required RAM
#SBATCH --partition=hugemem-avx2                    # Partition
#SBATCH --mail-user=amulya.baral@nmbu.no            # Email when job is done
#SBATCH --mail-type=ALL

cd /mnt/project/AntibiotiKU/gtdb_db
tar -xzf gtdbtk_r220_data.tar.gz
