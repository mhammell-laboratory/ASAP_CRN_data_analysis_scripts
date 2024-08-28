# ASAP_CRN_data_analysis_scripts

## Overview
These are the scripts used in data analysis for ASAP CRN dataset, "Single nuclei sequencing of brain regions from healthy and Parkinson's Disease individuals", from Team Jakobsson. It comprises two sets of information:
1) [Shell script](https://github.com/mhammell-laboratory/ASAP_CRN_data_analysis_scripts/blob/main/snRNA_analysis/generate_custom_cell_ranger_database.sh) to generate a Cell Ranger compatible reference database containing transposable element annotations
2) [YAML file](https://github.com/mhammell-laboratory/ASAP_CRN_data_analysis_scripts/tree/main/snRNA_analysis) containing software, database and parameters used fo the Cell Ranger count runs to generate the snRNA count matrices

## System Requirements & Dependencies
- [Cell Ranger software](https://www.10xgenomics.com/support/software/cell-ranger/downloads) (tested on version 5.0.1)
- wget (tested on version 1.19.5)
- Standard Linux tools (e.g. awk, grep, zcat)

Since the pipeline requires the 10x Genomics Cell Ranger software, you will need to fulfil [their system requirements](https://www.10xgenomics.com/support/software/cell-ranger/downloads/cr-system-requirements)
>Cell Ranger pipelines run on Linux systems that meet these minimum requirements:
>   - 8-core Intel or AMD processor (16 cores recommended), with support for instruction sets including at least SSE4.2. This includes Intel CPUs released since 2008 (Core i5/i7 or newer) and any AMD CPU since 2011. Future versions of Cell Ranger will require CPUs supporting AVX instructions; Intel and AMD CPUs have supported these since 2011 (Intel Xeon E3/E5 or newer).
>   - 64GB RAM (128GB recommended).
>   - 1TB free disk space.
>   - 64-bit CentOS/RedHat 7.0 or Ubuntu 14.04

## Installation
The script to generate the custom Cell Ranger reference database can be donwloaded and run without additional installation steps.
The YAML file contains the command line parameters used to run the analysis using Cell Ranger, and require no installation steps.

## Usage
### Shell script
```bash
$ sh generate_custom_cell_ranger_database.sh
```
This should generate a folder, `GRCh38_GCv35_TE`, containing the Cell Ranger custom reference database.
``` bash
$ ls
GRCh38_GCv35_TE/
GRCh38_GCv35_TE.gtf
GRCh38.primary_assembly.genome.fa.gz
GRCh38_GENCODE_rmsk_TE_filtered.gtf
GRCh38_GENCODE_rmsk_TE.gtf.gz
gencode.v35.primary_assembly.annotation_CRfiltered.gtf
gencode.v35.primary_assembly.annotation.allowed
gencode.v35.primary_assembly.annotation.modified
gencode.v35.primary_assembly.annotation.gtf.gz
generate_custom_cell_ranger_database.sh
```
### YAML
The YAML file contains the command to be used for Cell Ranger to generate the count matrices. For example
```bash
$ cellranger count --id=ASAP1_SN --jobmode=local --localcores=16 --localmem=128 --transcriptome=GRCh38_GCv35_TE --fastqs=fastqs --sample=ASAP1_PD_NP16-162_SN --include-introns
```

## Limitation
The custom databases generation script is specific to GENCODE annotation version 35. If you require another version, please modify the script to download the corresponding annotation.

## Questions and issues
Please feel free to use the [Issues page](https://github.com/mhammell-laboratory/ASAP_CRN_data_analysis_scripts/issues) to post any questions or issues.

You can also contact mghcompbio@gmail.com if you have not received a response more than a week after posting on the Issues page.

## Citation
Please cite this software using the citation file format file included with the repository.
Further citations will be added upon publication of associated project.

## Licence
This software is distributed under the MIT licence per ASAP Open Access (OA) policy, which facilitates the rapid and free exchange of scientific ideas and ensures that ASAP-funded research fund can be leveraged for future discoveries.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

A copy of this licence is included along with the software, and can be accessed [here](https://github.com/mhammell-laboratory/ASAP_CRN_data_analysis_scripts/blob/main/LICENSE).

## Acknowledgment
- Contributors: Anita Adami, Talitha Forcier, Raquel Garza, Annelies Quagebeur, Yogita Sharma, Oliver Tam, Cole Wunderlich, Roger Barker, Molly Gale Hammell, Agnete Kirkeby and Johan Jakobsson

This research was funded in whole by Aligning Science Across Parkinson’s (ASAP-000520) through the Michael J. Fox Foundation for Parkinson’s Research (MJFF).
