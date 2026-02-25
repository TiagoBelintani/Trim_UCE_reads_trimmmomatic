
# Trim_UCE_reads_trimmomatic

This tutorial describes how to trim Illumina paired-end reads from both Ultra-Conserved Element (UCE) capture datasets and transcriptome (RNA-Seq) datasets using Trimmomatic.

In general, the Phyluce package provides a comprehensive framework to process UCE data from raw reads to phylogenetic matrices:

https://phyluce.readthedocs.io/en/latest/purpose.html

Within that framework, trimming is performed using the wrapper Illumiprocessor, which internally calls Trimmomatic.

Illumiprocessor documentation:
https://phyluce.readthedocs.io/en/latest/purpose.html

Trimmomatic repository:
https://github.com/usadellab/Trimmomatic

However, there are situations where it is advantageous to run trimming independently of Phyluce, including:

- Custom parameter optimization
- Mixed datasets (UCE + transcriptomes)
- HPC-specific tuning
- Adapter structure inspection
- Benchmarking trimming strategies
- Debugging read quality issues
- Teaching and methodological transparency

This repository provides a portable, trimming-only workflow that:

- Mimics the logical structure of Illumiprocessor
- Supports multi-sample automated execution
- Works for both UCE genomic libraries and RNA-Seq transcriptomes
- Produces organized per-sample output
- Includes pre- and post-trimming quality assessment
- Runs locally or on SLURM-based HPC systems

No assembly is performed here — this workflow focuses exclusively on read cleaning and quality control, which is the foundational step for any downstream analysis.

---

# Why Separate UCE and Transcriptome Trimming?

Although both datasets originate from Illumina sequencing, their biological and technical properties differ.

## UCE Libraries

- Derived from genomic DNA
- Often short insert sizes
- High probability of adapter read-through
- Sensitive to trimming thresholds
- Downstream goal: phylogenomics

## Transcriptomes (RNA-Seq)

- Derived from cDNA synthesized from RNA
- Highly variable transcript abundance
- Sensitive to aggressive trimming
- Risk of losing low-expression transcripts
- Downstream goal: assembly, orthology inference, expression analyses

Because of these differences, trimming parameters must be interpreted biologically rather than applied generically.

This tutorial explains:

- What each Trimmomatic parameter does
- Why it matters biologically
- How trimming strategies differ between UCE and RNA datasets
- How to evaluate trimming success using FastQC and MultiQC

FastQC:
https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

MultiQC:
https://multiqc.info/ 

---

# Complete Workflow Overview

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
# Citation

Bolger AM, Lohse M, Usadel B. 2014.  
Trimmomatic: a flexible trimmer for Illumina sequence data.  
Bioinformatics.

**Tiago Belintani** *Brave the Sun*
