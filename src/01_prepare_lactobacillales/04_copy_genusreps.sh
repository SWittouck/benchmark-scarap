#!/usr/bin/env bash 

# This script will copy the faa files of Lactobacillales genus representatives
# to a dedicated folder from a folder with faa files of Lactobacillales species 
# representatives. 

# specify paths
din_speciesreps=../../results/lactobacillales/speciesreps/faas
fin_genusreps=../../data/lactobacillales/accessions_genusreps.tsv
dout_genusreps=../../results/lactobacillales/genusreps

# create output folders
[ -d $dout_genusreps ] || mkdir $dout_genusreps
[ -d $dout_genusreps/faas ] || mkdir $dout_genusreps/faas

# copy faa files of genus representatives
for acc in $(cat $fin_genusreps | cut -f 1) ; do
  cp $din_speciesreps/$acc.faa.gz $dout_genusreps/faas
done