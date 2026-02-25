# Trimmomatic UCE Tutorial (HPC + SLURM Ready)

Reproducible and portable pipeline for trimming paired-end Illumina
reads using Trimmomatic in local environments and SLURM-based HPC
clusters.

------------------------------------------------------------------------

# Overview

This repository provides:

-   Reproducible installation via Conda or manual setup
-   Automated execution for multiple samples
-   SLURM-compatible job scripts
-   Organized HPC-ready structure
-   Complete quality control workflow
-   Scientific justification for trimming decisions

Main software:

Trimmomatic -- read trimming software for Illumina sequencing data

------------------------------------------------------------------------

# Repository Structure

Trim_UCE_reads_trimmomatic/ │ ├── README.md\
├── INSTALL.md\
├── HPC_SLURM_GUIDE.md\
├── environment.yml\
│\
├── scripts/\
│ ├── trimmomatic_job.slurm\
│ ├── auto_trim.sh\
│ └── rename_reads.sh

------------------------------------------------------------------------

# Installation Guide

## Step 1 -- Activate Conda

If using Anaconda:

source \~/anaconda3/bin/activate

If using Miniconda:

source \~/miniconda3/bin/activate

Verify installation:

conda --version

------------------------------------------------------------------------

## Step 2 -- Create Dedicated Environment

conda create -n uce_processing -y\
conda activate uce_processing

------------------------------------------------------------------------

## Step 3 -- Install Trimmomatic

Recommended (Bioconda):

conda install -c bioconda trimmomatic

Alternative (manual installation):

cd \~/programs\
git clone https://github.com/usadellab/Trimmomatic.git\
cd Trimmomatic

Test JAR manually:

java -jar /full/path/to/trimmomatic-0.39.jar -version

------------------------------------------------------------------------

## Step 4 -- Test Installation

trimmomatic --version

Expected output:

TrimmomaticPE: Version 0.39

------------------------------------------------------------------------

## Export Environment for Reproducibility

conda env export \> environment.yml

To recreate environment:

conda env create -f environment.yml

------------------------------------------------------------------------

# Quality Assessment with FastQC

Before trimming, evaluate raw reads:

fastqc sample_R1.fastq.gz sample_R2.fastq.gz

Key metrics to inspect:

-   Per base sequence quality
-   Adapter content
-   Overrepresented sequences
-   Per sequence GC content

After trimming, run FastQC again to confirm improvements.

------------------------------------------------------------------------

# Trimmomatic Command (Portable Version)

Define symbolic paths:

TRIMMOMATIC_JAR="/path/to/trimmomatic.jar"\
ADAPTERS="/path/to/adapters/TruSeq_all_PE.fa"\
RAW_R1="sample_R1.fastq.gz"\
RAW_R2="sample_R2.fastq.gz"\
OUT_DIR="trimmed_reads"\
THREADS=20

Create output directory:

mkdir -p \${OUT_DIR}

Execute trimming:

java -jar \${TRIMMOMATIC_JAR} PE\
-threads \${THREADS}\
-phred33\
\${RAW_R1} \${RAW_R2}\
\${OUT_DIR}/sample_R1_paired.fastq.gz\
\${OUT_DIR}/sample_R1_unpaired.fastq.gz\
\${OUT_DIR}/sample_R2_paired.fastq.gz\
${OUT_DIR}/sample_R2_unpaired.fastq.gz \
 ILLUMINACLIP:${ADAPTERS}:2:30:10:2:keepBothReads\
LEADING:1\
TRAILING:1\
SLIDINGWINDOW:5:20\
MINLEN:50\
2\> \${OUT_DIR}/trimmomatic.log

------------------------------------------------------------------------

# Parameter Explanation

PE\
Paired-end mode.

-threads\
Number of CPU threads used.

-phred33\
Specifies Phred+33 quality encoding.

ILLUMINACLIP\
Removes adapter sequences.

Format: ILLUMINACLIP:adapters.fa:2:30:10:2:keepBothReads

LEADING:1\
Removes low-quality bases from the start.

TRAILING:1\
Removes low-quality bases from the end.

SLIDINGWINDOW:5:20\
Cuts when average quality within a 5-base window drops below 20.

MINLEN:50\
Discards reads shorter than 50 bp after trimming.

------------------------------------------------------------------------

# Output Files

sample_R1_paired.fastq.gz\
sample_R1_unpaired.fastq.gz\
sample_R2_paired.fastq.gz\
sample_R2_unpaired.fastq.gz

Paired reads are typically used for assembly.\
Unpaired reads may be retained or discarded depending on downstream
pipeline.

------------------------------------------------------------------------

# Impact on Assembly

Proper trimming:

-   Improves average read quality
-   Reduces assembly fragmentation
-   Increases contig reliability
-   Enhances UCE locus recovery
-   Reduces misassemblies

Recommended assemblers for UCE workflows:

-   SPAdes
-   Trinity
-   Velvet

------------------------------------------------------------------------

# SLURM Execution

Submit job:

sbatch scripts/trimmomatic_job.slurm

Monitor queue:

squeue -u \$USER

------------------------------------------------------------------------

# Complete Workflow

Raw Data\
↓\
Initial FastQC\
↓\
Trimmomatic\
↓\
Post-trim FastQC\
↓\
Assembly\
↓\
UCE locus recovery

------------------------------------------------------------------------

# Citation

Bolger AM, Lohse M, Usadel B. 2014.\
Trimmomatic: a flexible trimmer for Illumina sequence data.
Bioinformatics.

------------------------------------------------------------------------

# Author

Tiago Belintani\
2026
*Brave the sun*









