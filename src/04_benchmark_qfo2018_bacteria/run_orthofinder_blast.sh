#!/usr/bin/env bash

# dependency: orthofinder version 2.3.11

din_faas=../../results/qfo2018_bacteria/proteomes
dout=../../results/qfo2018_bacteria/benchmarks/orthofinder_blast

threads=16

# make output folder if doesn't exist
[ -d $dout ] || mkdir $dout  

# copy faa files to output folder
cp $din_faas/*.faa.gz $dout

# unzip faa files
gunzip $dout/*.faa.gz

# set timer to zero
SECONDS=0

# run orthofinder 
orthofinder -og -S blast -t $threads -f $dout

# save time 
echo $SECONDS > $dout/time.txt

# remove faa files
rm $dout/*.faa
