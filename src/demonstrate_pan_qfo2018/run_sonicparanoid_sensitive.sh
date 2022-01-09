#!/usr/bin/env bash

# dependency: sonicparanoid version 1.3.0

din_faas=../../results/qfo2018_bacteria/proteomes
dout=../../results/qfo2018_bacteria/benchmarks/sonicparanoid_sensitive

threads=16

# unzip faa files
gunzip $din_faas/*.faa.gz

# set timer to zero
SECONDS=0

# run sonicparanoid
sonicparanoid -i $din_faas -o $dout -m sensitive -t $threads

# save time 
echo $SECONDS > $dout/time.txt

# rezip faa files 
gzip $din_faas/*.faa
