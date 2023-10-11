# ASAP_CRN_data_analysis_scripts
Scripts used in data analysis for ASAP CRN projects

## Single nuclei sequencing of brain regions from healthy and Parkinson's Disease individuals
The relevant information is located in the snRNA_analysis folder. It contains two files:
- generate_custom_cell_ranger_database.sh: a script that will generate the custom Cell Ranger reference database to include transposable elements (TE).
- configuration.yaml: a YAML file containing the software, database and parameters used for the Cell Ranger count runs to generate the count matrices.
