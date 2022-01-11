#!/usr/bin/env bash

# This script will download representative genomes of the species of the order
# Lactobacillales. (Genus representatives are a subset of this dataset.)

# dependencies: Proclasp v1.0

fin_accessions=../../data/lactobacillales/accessions_speciesreps.tsv
fout_log=../../results/lactobacillales/download_fnas.log
dout_genomes=../../data/lactobacillales/genomes_ncbi

if ! [ -d $dout_genomes ] ; then

  download_fnas.sh \
    $fin_accessions \
    $dout_genomes \
    2>&1 | tee $fout_log

fi