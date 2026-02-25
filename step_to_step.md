
# Trimmomatic UCE Tutorial (HPC + SLURM Ready)

Reproducible and portable trimming-only pipeline for paired-end Illumina reads using Trimmomatic.

This workflow behaves similarly to Illumiprocessor:
- Accepts adapter definitions
- Processes samples automatically
- Renames outputs cleanly (READ1 / READ2)
- Organizes output per sample
- Generates quality reports
- Supports SLURM environments

No assembly is performed in this workflow.

---

# Overview

This repository provides:

- Reproducible installation via Conda
- Illumiprocessor-like adapter handling
- Multi-sample automated trimming
- Structured output per sample
- FastQC before and after trimming
- MultiQC report aggregation
- SLURM compatibility

Main software:

Trimmomatic — adapter and quality trimming tool for Illumina sequencing data

---

# Repository Structure

```bash
Trim_UCE_reads_trimmomatic/
├── README.md
├── environment.yml
├── config.sh
├── run_trimming.sh
├── run_trimming.slurm
└── data/
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

Install required tools:

```bash
conda install -c bioconda trimmomatic fastqc multiqc -y
```

Export environment:

```bash
conda env export > environment.yml
```

---

# Configuration File (config.sh)

```bash
#!/bin/bash

THREADS=20
PHRED="-phred33"

TRIMMOMATIC_JAR="$(which trimmomatic)"
ADAPTERS="/path/to/TruSeq_all_PE.fa"

MODE="UCE"   # Options: UCE or RNA
```

---

# How Adapter Handling Works

Illumiprocessor dynamically inserts sample-specific index sequences into adapter templates.

Trimmomatic does not insert indexes dynamically.

Instead:
- You provide a FASTA file with adapter sequences.
- Trimmomatic searches and removes matching adapter contamination.
- It trims read-through fragments.

If demultiplexing was correctly performed by the sequencing facility, index sequences are already removed. Do not manually insert i7/i5 indexes unless FastQC shows contamination.

---

# Main Trimming Script (run_trimming.sh)

```bash
#!/bin/bash

source config.sh

mkdir -p results
mkdir -p logs

for R1 in data/*_R1.fastq.gz
do
    SAMPLE=$(basename ${R1} _R1.fastq.gz)
    R2=data/${SAMPLE}_R2.fastq.gz

    echo "Processing ${SAMPLE}"

    BASE="results/${SAMPLE}"
    mkdir -p ${BASE}/raw
    mkdir -p ${BASE}/trimmed
    mkdir -p ${BASE}/qc_raw
    mkdir -p ${BASE}/qc_trimmed
    mkdir -p ${BASE}/stats

    ln -sf ${R1} ${BASE}/raw/
    ln -sf ${R2} ${BASE}/raw/

    # FASTQC RAW
    fastqc ${R1} ${R2} -o ${BASE}/qc_raw

    # TRIMMING
    if [ "${MODE}" = "UCE" ]; then

        java -jar ${TRIMMOMATIC_JAR} PE             -threads ${THREADS}             ${PHRED}             ${R1} ${R2}             ${BASE}/trimmed/${SAMPLE}-READ1.fastq.gz             ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz             ${BASE}/trimmed/${SAMPLE}-READ2.fastq.gz             ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz             ILLUMINACLIP:${ADAPTERS}:2:30:10:8:true             LEADING:5 TRAILING:5             SLIDINGWINDOW:4:18             MINLEN:45             2> ${BASE}/stats/${SAMPLE}_trim.log

    else

        java -jar ${TRIMMOMATIC_JAR} PE             -threads ${THREADS}             ${PHRED}             ${R1} ${R2}             ${BASE}/trimmed/${SAMPLE}-READ1.fastq.gz             ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz             ${BASE}/trimmed/${SAMPLE}-READ2.fastq.gz             ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz             ILLUMINACLIP:${ADAPTERS}:2:30:10:2:true             LEADING:3 TRAILING:3             SLIDINGWINDOW:4:20             MINLEN:50             2> ${BASE}/stats/${SAMPLE}_trim.log

    fi

    # FASTQC TRIMMED
    fastqc         ${BASE}/trimmed/${SAMPLE}-READ1.fastq.gz         ${BASE}/trimmed/${SAMPLE}-READ2.fastq.gz         -o ${BASE}/qc_trimmed

done

# GLOBAL MULTIQC
multiqc results -o results/multiqc
```

Make executable:

```bash
chmod +x run_trimming.sh
```

Run locally:

```bash
bash run_trimming.sh
```

---

# SLURM Execution (run_trimming.slurm)

```bash
#!/bin/bash
#SBATCH --job-name=uce_trim
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=20
#SBATCH --mem=80G

module load miniconda
conda activate uce_trim

bash run_trimming.sh
```

Submit:

```bash
sbatch run_trimming.slurm
```

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

# Complete Workflow

Raw Data  
↓  
FastQC (raw)  
↓  
Trimmomatic  
↓  
FastQC (trimmed)  
↓  
MultiQC  

No assembly is performed.

---

# Citation

Bolger AM, Lohse M, Usadel B. 2014.  
Trimmomatic: a flexible trimmer for Illumina sequence data.  
Bioinformatics.


