#!/usr/bin/env bash

# This script downloads genomes of the genus Lactiplantibacillus from NCBI 
# GenBank. 

# dependencies: Proclasp v1.0

fin_accessions=../../data/lactiplantibacillus/accessions.txt
dout_log=../../data/lactiplantibacillus
dout_genomes=../../data/lactiplantibacillus/genomes_ncbi

# create output folder
[ -d $dout_log ] || mkdir $dout_log

# download genomes (fna files)
if ! [ -d $dout_genomes ] ; then

  download_fnas.sh \
    $fin_accessions \
    $dout_genomes \
    2>&1 | tee $dout_log/download_fnas.log

fi