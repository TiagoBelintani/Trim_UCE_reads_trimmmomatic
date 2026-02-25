#!/bin/bash
#SBATCH --job-name=uce_trim
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=20
#SBATCH --mem=80G

module load miniconda
conda activate uce_trim

bash run_trimming.sh
