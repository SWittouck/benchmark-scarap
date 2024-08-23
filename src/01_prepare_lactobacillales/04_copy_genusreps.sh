#!/usr/bin/env bash 

# This script copies the gff and faa files of Lactobacillales genus 
# representatives given in a txt file to a dedicated folder. Gff files are 
# needed by PIRATE and faa files by all other pangenome tools. 

# specify paths
fin_genusreps=../../data/lactobacillales/accessions_genusreps.tsv
din_gffs=../../results/lactobacillales/speciesreps/gffs
din_faas=../../results/lactobacillales/speciesreps/faas
dout_genusreps=../../results/lactobacillales/genusreps

# create output folders
[ -d $dout_genusreps ] || mkdir $dout_genusreps
[ -d $dout_genusreps/gffs ] || mkdir $dout_genusreps/gffs
[ -d $dout_genusreps/faas ] || mkdir $dout_genusreps/faas

# copy faa files of genus representatives
for acc in $(cat $fin_genusreps | cut -f 1) ; do
  cp $din_gffs/$acc.gff.gz $dout_genusreps/gffs
  cp $din_faas/$acc.faa.gz $dout_genusreps/faas
done