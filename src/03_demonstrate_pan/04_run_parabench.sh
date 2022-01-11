#!/usr/bin/env bash

# This script will run the ParaBench pangenome evaluation script on the 
# orthobench-formatted output of a number of pangenome tools. 

din_pangenomes=../../results/scarap_pan/parabench/orthobench_formatted
dout=../../results/scarap_pan/parabench/benchmarks

din_parabench_script=../../data/parabench/paraBench

# create output folder
[ -d $dout ] || mkdir $dout

# temporarily copy the reference file to the current dir
cp $din_parabench_script/reference_classification.txt ./

# evaluate tools
for fin_pangenome in $din_pangenomes/*.txt ; do
  tool=$(basename $fin_pangenome .txt)
  python3 $din_parabench_script/paraBench.py $fin_pangenome > $dout/$tool.txt
done

# remove the reference file from the current dir
rm ./reference_classification.txt