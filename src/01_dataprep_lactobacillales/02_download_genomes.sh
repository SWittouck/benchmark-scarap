#!/usr/bin/env bash

# dependencies: Proclasp v1.0

fin_accessions=../../data/genomes_lactobacillales.tsv
fout_log=../../results/lactobacillales/download_fnas.log
dout_genomes=../../data/genomes_lactobacillales_ncbi

if ! [ -d $dout_genomes ] ; then

  download_fnas.sh \
    $fin_accessions \
    $dout_genomes \
    2>&1 | tee $fout_log

fi