#!/usr/bin/env bash

# This script downloads representative genomes of the species of the order
# Lactobacillales. (Genus representatives are a subset of this dataset.)

# dependencies: Proclasp v1.0

fin_accessions=../../data/lactobacillales/accessions_speciesreps.tsv
dout_log=../../data/lactobacillales
dout_genomes=../../data/lactobacillales/genomes_ncbi

# create output folder
[ -d $dout_log ] || mkdir $dout_log

# download genomes (fna files)
if ! [ -d $dout_genomes ] ; then

  download_fnas.sh \
    $fin_accessions \
    $dout_genomes \
    2>&1 | tee $dout_log/download_fnas.log

fi