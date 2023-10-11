#!/bin/sh

### This script is used to the generate a Cell Ranger database that includes GENCODE version 35 and TE annotations

# Download primary assembly of genome sequence from GENCODE
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/GRCh38.primary_assembly.genome.fa.gz

FASTA="GRCh38.primary_assembly.genome.fa.gz"

# Download GENCODE version 35, primary assembly, comprehensive annotation GTF from GENCODE
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/gencode.v35.primary_assembly.annotation.gtf.gz

GTF_IN="gencode.v35.primary_assembly.annotation.gtf.gz"

# Download TE GTF from Molly Hammell lab website
wget https://labshare.cshl.edu/shares/mhammelllab/www-data/TEtranscripts/TE_GTF/GRCh38_GENCODE_rmsk_TE.gtf.gz

TE_IN="GRCh38_GENCODE_rmsk_TE.gtf.gz"

# Remove version suffix from transcript, gene, and exon IDs in order to match
# previous Cell Ranger reference packages
#
# Input GTF:
#     ... gene_id "ENSG00000223972.5"; ...
# Output GTF:
#     ... gene_id "ENSG00000223972"; gene_version "5"; ...

GTF_MOD="$(basename "${GTF_IN}" \.gz).modified"

## Pattern matches Ensembl gene, transcript, and exon IDs for human or mouse:
ID="(ENS(MUS)?[GTE][0-9]+)\.([0-9]+)"
zcat "${GTF_IN}" \
    | sed -E 's/gene_id "'"$ID"'";/gene_id "\1"; gene_version "\3";/' \
    | sed -E 's/transcript_id "'"$ID"'";/transcript_id "\1"; transcript_version "\3";/' \
    | sed -E 's/exon_id "'"$ID"'";/exon_id "\1"; exon_version "\3";/' \
	  > "${GTF_MOD}"

## Define string patterns for GTF tags
### NOTES:
### - Since GENCODE release 31/M22 (Ensembl 97), the "lincRNA" and "antisense"
###   biotypes are part of a more generic "lncRNA" biotype.
### - These filters are relevant only to GTF files from GENCODE. The GTFs from
###   Ensembl release 98 have the following differences:
###   - The names "gene_biotype" and "transcript_biotype" are used instead of
###     "gene_type" and "transcript_type".
###   - Readthrough transcripts are present but are not marked with the
###     "readthrough_transcript" tag.
###   - Only the X chromosome versions of genes in the pseudoautosomal regions
###     are present, so there is no "PAR" tag.
BIOTYPE_PATTERN=\
"(protein_coding|lncRNA|lincRNA|antisense\
IG_C_gene|IG_D_gene|IG_J_gene|IG_LV_gene|IG_V_gene|\
IG_V_pseudogene|IG_J_pseudogene|IG_C_pseudogene|\
TR_C_gene|TR_D_gene|TR_J_gene|TR_V_gene|\
TR_V_pseudogene|TR_J_pseudogene)"
GENE_PATTERN="gene_type \"${BIOTYPE_PATTERN}\""
TX_PATTERN="transcript_type \"${BIOTYPE_PATTERN}\""
READTHROUGH_PATTERN="tag \"readthrough_transcript\""
PAR_PATTERN="tag \"PAR\""

## Construct the gene ID allowlist.
### We filter the list of all transcripts based on these criteria:
###   - allowable gene_type (biotype)
###   - allowable transcript_type (biotype)
###   - no "PAR" tag (only present for Y chromosome PAR)
###   - no "readthrough_transcript" tag
### We then collect the list of gene IDs that have at least one associated
### transcript passing the filters.

ALLOWLIST="$(basename "${GTF_IN}" \.gtf\.gz).allowed"
cat "${GTF_MOD}" \
    | awk '$3 == "transcript"' \
    | grep -E "${GENE_PATTERN}" \
    | grep -E "${TX_PATTERN}" \
    | grep -Ev "${READTHROUGH_PATTERN}" \
    | grep -Ev "${PAR_PATTERN}" \
    | sed -E 's/.*(gene_id "[^"]+").*/\1/' \
    | sort \
    | uniq \
	  > "${ALLOWLIST}"

## Filter the GTF file based on the gene allowlist
GTF_FILTERED="$(basename "${GTF_IN}" \.gtf\.gz)_CRfiltered.gtf"

### Copy header lines beginning with "#"
grep -E "^#" "${GTF_MOD}" > "${GTF_FILTERED}"

### Filter to the gene allowlist
grep -Ff "${ALLOWLIST}" "${GTF_MOD}" \
     >> "${GTF_FILTERED}"

## Remove intermediate files
rm "${GTF_MOD}" "${ALLOWLIST}"

## Identify chromosomes present in the genome fasta file
CHRFILES="GRCh38_GENCODE_chrNames.txt"
grep ">" "${FASTA}" | sed 's/>//;s/ .*$//' | sort -k1,1 > "${CHRFILES}"

## Filter TE GTF file to include only primary assembly chromosomes
TE_FILTERED="$(basename "${TE_IN}" \.gtf\.gz)_filtered.gtf"
zcat "${TE_IN}" | sort -k1,1 | join -t "	" -j 1 "${CHRFILES}" - > "${TE_FILTERED}"

## Combine the two GTF into a single file for Cell Ranger
COMBINED_GTF="GRCh38_GCv35_TE.gtf"
cat "${GTF_FILTERED}" "${COMBINED_GTF}" > "${COMBINED_GTF}"

## Build the custom Cell Ranger reference database
cellranger mkref --genome="GRCh38_GCv35_TE" --fasta="${FASTA}" --genes="${COMBINED_GTF}" --memgb=40 --nthreads=10



