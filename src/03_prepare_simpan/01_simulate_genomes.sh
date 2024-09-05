#!/usr/bin/env bash 

# This script simulates 100 bacterial genomes with the SimPan tool. 

# dependencies: python, SimBac, SimPan 

simpan=../../lib/SimPan-0.1/SimPan.py
dout=../../results/simpan

# create output folder 
[ -dout $dout ] || mkdir $dout 

# simulate genomes
python $simpan --genomeNum 100 --aveSize 2500 --nBackbone 2000 --nMobile 10000 \
  --idenOrtholog 0.90 -p $dout/genome

# reorganize output
mkdir $dout/fnas 
mkdir $dout/pgffs
mkdir $dout/tbls
mv $dout/*.fna $dout/fnas
mv $dout/*.gff $dout/pgffs 
mv $dout/*.tbl $dout/tbls
gzip $dout/fnas/*.fna
gzip $dout/pgffs/*.gff