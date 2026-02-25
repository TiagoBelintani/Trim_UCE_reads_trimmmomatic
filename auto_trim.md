
# Multi-Sample Trimmomatic Pipeline (UCE + Transcriptome)
HPC + SLURM Ready | Illumiprocessor-like Structure

---

## Overview

This document describes an automated multi-sample trimming pipeline using **Trimmomatic** designed for:

- UCE (Ultra-Conserved Element) genomic libraries
- RNA-Seq transcriptomes

This implementation mimics the structural logic of Illumiprocessor while remaining lightweight, transparent, and fully customizable.

The pipeline:

- Processes multiple samples automatically
- Validates paired-end naming (_R1 / _R2)
- Organizes output per sample
- Runs FastQC before and after trimming
- Aggregates reports with MultiQC
- Works locally or on SLURM HPC systems
- Uses a central configuration file (config.sh)

No assembly is performed in this workflow.

---

# Repository Structure

```bash
Trim_UCE_reads_trimmomatic/
├── config.sh
├── scripts/
│   └── auto_trim.sh
├── data/
│   ├── sample1_R1.fastq.gz
│   ├── sample1_R2.fastq.gz
│   ├── sample2_R1.fastq.gz
│   └── sample2_R2.fastq.gz
└── results/
```

---

# Installation

Activate Conda:

```bash
source ~/miniconda3/bin/activate
```

Create environment:

```bash
conda create -n uce_trim -y
conda activate uce_trim
```

Install required software:

```bash
conda install -c bioconda trimmomatic fastqc multiqc -y
```

Export environment for reproducibility:

```bash
conda env export > environment.yml
```

---

# Configuration File (config.sh)

This file centralizes pipeline parameters.

```bash
#!/bin/bash

THREADS=20
PHRED="-phred33"

TRIMMOMATIC_JAR="$(which trimmomatic)"
ADAPTERS="/path/to/TruSeq_all_PE.fa"

MODE="UCE"   # Options: UCE or RNA
```

## Parameter Explanation

THREADS  
Number of CPU threads used.

PHRED  
Defines quality encoding (modern Illumina = phred33).

TRIMMOMATIC_JAR  
Path to Trimmomatic executable.

ADAPTERS  
Path to adapter FASTA file.

MODE  
Defines trimming strategy:
- UCE → more aggressive adapter control
- RNA → more conservative trimming

---

# Main Script (scripts/auto_trim.sh)

```bash
#!/bin/bash

source config.sh

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

if [[ $# -eq 0 ]]; then
    echo "Usage: bash auto_trim.sh data/*_R1.fastq.gz"
    exit 1
fi

for R1 in "$@"
do
    if [[ ! -f "$R1" ]]; then
        echo -e "${red}File not found:${reset} $R1"
        continue
    fi

    if [[ "$R1" != *_R1.* ]]; then
        echo -e "${red}Filename must contain _R1:${reset} $R1"
        continue
    fi

    SAMPLE=$(basename "$R1" | sed 's/_R1.*//')
    R2=$(echo "$R1" | sed 's/_R1/_R2/')

    if [[ ! -f "$R2" ]]; then
        echo -e "${red}Missing R2 pair:${reset} $R2"
        continue
    fi

    echo -e "\n${yellow}Processing:${reset} ${SAMPLE}"

    BASE="results/${SAMPLE}"
    mkdir -p ${BASE}/{raw,trimmed,qc_raw,qc_trimmed,stats}

    ln -sf ${R1} ${BASE}/raw/
    ln -sf ${R2} ${BASE}/raw/

    fastqc ${R1} ${R2} -o ${BASE}/qc_raw

    if [[ "${MODE}" == "UCE" ]]; then
        TRIM_PARAMS="ILLUMINACLIP:${ADAPTERS}:2:30:10:8:true                      LEADING:5 TRAILING:5                      SLIDINGWINDOW:4:18                      MINLEN:45"
    else
        TRIM_PARAMS="ILLUMINACLIP:${ADAPTERS}:2:30:10:2:true                      LEADING:3 TRAILING:3                      SLIDINGWINDOW:4:20                      MINLEN:50"
    fi

    java -jar ${TRIMMOMATIC_JAR} PE         -threads ${THREADS}         ${PHRED}         ${R1} ${R2}         ${BASE}/trimmed/${SAMPLE}-READ1.fastq.gz         ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz         ${BASE}/trimmed/${SAMPLE}-READ2.fastq.gz         ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz         ${TRIM_PARAMS}         2> ${BASE}/stats/${SAMPLE}_trim.log

    fastqc         ${BASE}/trimmed/${SAMPLE}-READ1.fastq.gz         ${BASE}/trimmed/${SAMPLE}-READ2.fastq.gz         -o ${BASE}/qc_trimmed

    echo -e "${green}Finished:${reset} ${SAMPLE}"

done

multiqc results -o results/multiqc
```

---

# How It Works

1. Validates paired-end naming (_R1 / _R2)
2. Creates per-sample directory structure
3. Runs FastQC on raw reads
4. Executes Trimmomatic with MODE-specific parameters
5. Runs FastQC on trimmed reads
6. Generates MultiQC report across all samples

---

# Output Structure

```bash
results/
├── sample1/
│   ├── raw/
│   ├── trimmed/
│   │   ├── sample1-READ1.fastq.gz
│   │   ├── sample1-READ2.fastq.gz
│   │   └── sample1-singletons.fastq.gz
│   ├── qc_raw/
│   ├── qc_trimmed/
│   └── stats/
└── multiqc/
```

---

# Biological Interpretation of Parameters

ILLUMINACLIP  
Removes adapter contamination and read-through fragments.

LEADING / TRAILING  
Removes low-quality bases at read ends.

SLIDINGWINDOW  
Cuts reads when average quality in a sliding window drops below threshold.

MINLEN  
Prevents retention of very short fragments that may cause mapping artifacts.

UCE mode uses slightly stricter adapter handling because short inserts are common.
RNA mode is more conservative to avoid removing low-expression transcripts.

---

# SLURM Example

```bash
#!/bin/bash
#SBATCH --job-name=uce_trim
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=20
#SBATCH --mem=80G

module load miniconda
conda activate uce_trim

bash scripts/auto_trim.sh data/*_R1.fastq.gz
```

Submit with:

```bash
sbatch run_trimming.slurm
```

---

# Workflow Summary

Raw Data  
↓  
FastQC (raw)  
↓  
Trimmomatic  
↓  
FastQC (trimmed)  
↓  
MultiQC  

---

# Citation

Bolger AM, Lohse M, Usadel B. 2014.  
Trimmomatic: a flexible trimmer for Illumina sequence data.  
Bioinformatics.
