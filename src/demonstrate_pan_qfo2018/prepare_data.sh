#!/usr/bin/env bash  

# This script copies the proteomes from the Quest for Orthologs 2018 Bacteria
# dataset. 

din=../../data/QfO_release_2018_04/Bacteria
dout=../../results/qfo2018_bacteria/proteomes

# create output folder if doesn't exist
[ -d $dout ] || mkdir $dout  

# copy only the proteome files 
cp $(ls $din/* | grep -E "/[^_]+_[^_]+\.fasta$") $dout

# change extension from .fasta to .faa
for fin in $dout/*.fasta ; do mv $fin ${fin%.fasta}.faa ; done 

# zip faa files
gzip $dout/*.faa