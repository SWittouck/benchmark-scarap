#!/usr/bin/env bash

# dependencies: SCARAP v0.3.1

din_faas=../../results/lactobacillales/genes/faas
dout=../../results/lactobacillales/benchmarks/scarap_H

threads=16

# set timer to zero
SECONDS=0

# create output folder 
[ -d $dout ] || mkdir -p $dout

# run scarap (with -c option to avoid starting a new output directory)
ls $din_faas/*.faa.gz > $dout/faapaths.txt
scarap pan $dout/faapaths.txt $dout --method H --threads $threads -c

# save time 
echo $SECONDS > $dout/time.txt
