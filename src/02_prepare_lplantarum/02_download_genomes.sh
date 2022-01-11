#!/usr/bin/env bash

# This script will download genomes of the species Lactiplantibacillus plantarum
# from NCBI GenBank. 

# dependencies: Proclasp v1.0

fin_accessions=../../data/lplantarum/accessions.txt
dout_log=../../results/lplantarum
dout_genomes=../../data/lplantarum/genomes_ncbi

# create output folder
[ -d $dout_log ] || mkdir $dout_log

# download genomes (fna files)
if ! [ -d $dout_genomes ] ; then

  download_fnas.sh \
    $fin_accessions \
    $dout_genomes \
    2>&1 | tee $dout_log/download_fnas.log

fi