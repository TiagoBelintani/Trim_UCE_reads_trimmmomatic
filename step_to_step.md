Trimmomatic UCE Tutorial (HPC + SLURM Ready)

Reproducible and portable trimming-only pipeline for paired-end Illumina reads using Trimmomatic.

This workflow behaves similarly to Illumiprocessor:

accepts adapter definitions

processes samples automatically

renames outputs cleanly

organizes output per sample

generates quality reports

No assembly is performed.

Overview

This repository provides:

Reproducible installation via Conda

Illumiprocessor-like adapter handling

Multi-sample automated trimming

Structured output per sample

FastQC before and after trimming

MultiQC report aggregation

SLURM compatibility

Main software:

Trimmomatic — adapter and quality trimming tool for Illumina data

Repository Structure
Trim_UCE_reads_trimmomatic/
├── README.md
├── environment.yml
├── config.sh
├── run_trimming.sh
├── run_trimming.slurm
└── data/
Installation

Activate Conda:

source ~/miniconda3/bin/activate

Create environment:

conda create -n uce_trim -y
conda activate uce_trim

Install required tools:

conda install -c bioconda trimmomatic fastqc multiqc -y

Export environment:

conda env export > environment.yml
Configuration File (config.sh)

This file mimics Illumiprocessor adapter configuration.

#!/bin/bash

THREADS=20
PHRED="-phred33"

TRIMMOMATIC_JAR="$(which trimmomatic)"
ADAPTERS="/path/to/TruSeq_all_PE.fa"

# Mode: UCE or RNA
MODE="UCE"
How Adapters Work (Illumiprocessor Concept)

Illumiprocessor inserts sample-specific indexes into adapter templates.

Trimmomatic does not insert indexes dynamically.

Instead:

You provide a FASTA file with adapter sequences

Trimmomatic searches and removes matches

It trims read-through fragments

If demultiplexing was done correctly by the sequencer:
Indexes are already removed.
You should NOT add i7/i5 sequences manually unless FastQC shows contamination.

Main Trimming Script (run_trimming.sh)
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

    ################################################
    # FASTQC RAW
    ################################################

    fastqc ${R1} ${R2} -o ${BASE}/qc_raw

    ################################################
    # TRIMMING
    ################################################

    if [ "${MODE}" = "UCE" ]; then

        java -jar ${TRIMMOMATIC_JAR} PE \
            -threads ${THREADS} \
            ${PHRED} \
            ${R1} ${R2} \
            ${BASE}/trimmed/${SAMPLE}-READ1.fastq.gz \
            ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz \
            ${BASE}/trimmed/${SAMPLE}-READ2.fastq.gz \
            ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz \
            ILLUMINACLIP:${ADAPTERS}:2:30:10:8:true \
            LEADING:5 TRAILING:5 \
            SLIDINGWINDOW:4:18 \
            MINLEN:45 \
            2> ${BASE}/stats/${SAMPLE}_trim.log

    else

        java -jar ${TRIMMOMATIC_JAR} PE \
            -threads ${THREADS} \
            ${PHRED} \
            ${R1} ${R2} \
            ${BASE}/trimmed/${SAMPLE}-READ1.fastq.gz \
            ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz \
            ${BASE}/trimmed/${SAMPLE}-READ2.fastq.gz \
            ${BASE}/trimmed/${SAMPLE}-singletons.fastq.gz \
            ILLUMINACLIP:${ADAPTERS}:2:30:10:2:true \
            LEADING:3 TRAILING:3 \
            SLIDINGWINDOW:4:20 \
            MINLEN:50 \
            2> ${BASE}/stats/${SAMPLE}_trim.log

    fi

    ################################################
    # FASTQC TRIMMED
    ################################################

    fastqc \
        ${BASE}/trimmed/${SAMPLE}-READ1.fastq.gz \
        ${BASE}/trimmed/${SAMPLE}-READ2.fastq.gz \
        -o ${BASE}/qc_trimmed

done

################################################
# GLOBAL MULTIQC
################################################

multiqc results -o results/multiqc

Make executable:

chmod +x run_trimming.sh

Run:

bash run_trimming.sh
Output Structure (Illumiprocessor-like)
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
What Each Parameter Means (Scientific Explanation)

ILLUMINACLIP
Removes adapter contamination and read-through fragments.

2:30:10

seed mismatches allowed

palindrome clip threshold

simple clip threshold

LEADING / TRAILING
Removes low-quality bases at ends (HiSeq edges often degrade).

SLIDINGWINDOW
Cuts read when local quality drops.

MINLEN
Removes excessively short fragments that harm downstream analysis.

Why This Improves UCE Data

UCE libraries often have:

Short inserts

Adapter read-through

Quality decay at ends

Proper trimming:

Improves mapping to probes

Reduces false UCE recovery

Improves downstream alignment

Stabilizes phylogenetic signal

SLURM Execution

run_trimming.slurm:

#!/bin/bash
#SBATCH --job-name=uce_trim
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=20
#SBATCH --mem=80G

module load miniconda
conda activate uce_trim

bash run_trimming.sh

Submit:

sbatch run_trimming.slurm
Complete Workflow Summary

Raw Data
↓
FastQC (raw)
↓
Trimmomatic
↓
FastQC (trimmed)
↓
MultiQC

No assembly performed.

Se você quiser, posso agora:

Gerar o .md final para download

Ajustar para aceitar arquivo de adapters estilo illumiprocessor.conf

Adicionar suporte a dual-index config

Tornar ainda mais semelhante ao Illumiprocessor real

Qual nível de fidelidade você quer alcançar?





