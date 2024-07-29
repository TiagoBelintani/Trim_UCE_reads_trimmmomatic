v#!/bin/bash
#SBATCH -t 20:00:00        # Maximum execution time (20 hours)
#SBATCH -c 40              # Number of CPU cores per task
#SBATCH --mail-user=tiago.belintani@unesp.br    # Your email for notifications
#SBATCH --mail-type=ALL    # Types of email notifications (ALL sends emails at the start, end, and in case of failures)

# Load the Miniconda environment
module load miniconda/3-2023-09

# Activate the desired Conda environment
source activate /home/tiagobelintani/miniconda3/envs/phylogenetic

# Define input and output directories
INPUT_DIR="/home/tiagobelintani/uce_treinamento/raw_data"
OUTPUT_DIR="/home/tiagobelintani/uce_treinamento/trimmed_data"

# Check if the output directory exists, create it if not
mkdir -p $OUTPUT_DIR

# Get the list of input files
FILES=($INPUT_DIR/*.fastq.gz)

# Check if files were found
if [ ${#FILES[@]} -eq 0 ]; then
    echo "No fastq.gz files found in the input directory."
    exit 1
fi

# Pass all the found files to the auto_trim.sh script
# The auto_trim.sh script should be located in the same directory as this script or provide the full path
source auto_trim.sh "${FILES[@]}"
