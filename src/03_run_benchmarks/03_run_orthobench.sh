#!/usr/bin/env bash

# This script will run the OrthoBench pangenome evaluation script on the 
# orthobench-formatted output of a number of pangenome tools. 

din_faas=../../data/OrthoBench_v1.1/Input
din_pangenomes=../../results/benchmarks/orthobench/orthobench_formatted
dout=../../results/benchmarks/orthobench/benchmarks

fin_orthobench_script=../../data/OrthoBench_v1.1/benchmark.py

# create output folder
[ -d $dout ] || mkdir $dout

# unzip orthobench proteomes (necessary for orthobench python script to work)
gunzip $din_faas/*.fa.gz

# evaluate tools
for fin_pangenome in $din_pangenomes/*.txt ; do
  tool=$(basename $fin_pangenome .txt)
  $fin_orthobench_script $fin_pangenome > $dout/$tool.txt
done

# rezip proteoms
gzip $din_faas/*.fa
