#!/usr/bin/env bash

# dependency: orthofinder version 2.3.11

din_faas=../../results/lactobacillales/genes/faas
dout=../../results/lactobacillales/benchmarks/orthofinder_blast

threads=16

# set timer to zero
SECONDS=0

# make output folder if doesn't exist
[ -d $dout ] || mkdir $dout  

# copy faa files to output folder
cp $din_faas/*.faa.gz $dout

# unzip faa files
gunzip $dout/*.faa.gz

# run orthofinder 
orthofinder -og -S blast -t $threads -f $dout

# remove faa files
rm $dout/*.faa

# save time 
echo $SECONDS > $dout/time.txt
