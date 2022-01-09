#!/usr/bin/env bash

# This script will download representative genomes of the genera of the order
# Lactobacillales. 

# dependencies: Proclasp v1.0

fin_accessions=../../data/lactobacillales_genera/genomes.tsv
fout_log=../../results/lactobacillales_genera/download_fnas.log
dout_genomes=../../data/lactobacillales_genera/genomes_ncbi

if ! [ -d $dout_genomes ] ; then

  download_fnas.sh \
    $fin_accessions \
    $dout_genomes \
    2>&1 | tee $fout_log

fi