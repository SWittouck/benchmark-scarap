#!/usr/bin/env bash

# dependencies: SCARAP v0.3.1

din_faas=../../results/qfo2018_bacteria/proteomes
dout=../../results/qfo2018_bacteria/benchmarks/scarap_FH

threads=16

# create output folder 
[ -d $dout ] || mkdir -p $dout

# set timer to zero
SECONDS=0

# run scarap (with -c option to avoid starting a new output directory)
ls $din_faas/*.faa > $dout/faapaths.txt
scarap pan $dout/faapaths.txt $dout --method FH --threads $threads -c

# save time 
echo $SECONDS > $dout/time.txt
