#!/usr/bin/env bash

# dependency: sonicparanoid version 1.3.0

din_faas=../../results/lactobacillales/genes/faas
dout=../../results/lactobacillales/benchmarks/sonicparanoid

threads=16

# set timer to zero
SECONDS=0

# unzip faa files
gunzip $din_faas/*.faa.gz

# run sonicparanoid
sonicparanoid -i $din_faas -o $dout -m sensitive -t $threads

# rezip faa files 
gzip $din_faas/*.faa

# save time 
echo $SECONDS > $dout/time.txt
