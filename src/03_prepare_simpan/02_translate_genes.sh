#!/usr/bin/env bash

# This script extracts CDS features from the simpan simulated genomes 
# and translates them to amino acid sequences.

# dependencies: genometools

din=../../results/simpan/pgffs
dout=../../results/simpan/faas

# make output folder 
[ -d $dout ] || mkdir $dout

# extract and translate genes
for fin_gff in $din/*.gff.gz ; do 

  # extract genome name
  genome=$( basename $fin_gff )
  genome=${genome%.gff.gz}
  echo $genome
  
  # extract contig sequences 
  zcat $fin_gff | awk '/##FASTA/{flag=1; next} flag' > $dout/$genome.fna
  
  # sort gff file (required for gt extractfeat)
  gt gff3 -sort -retainids $fin_gff > $dout/$genome.sorted.gff
  
  # extract and translate genes
  gt extractfeat -type "CDS" -seqfile $dout/$genome.fna -translate -gcode 11 \
    -matchdescstart -retainids -gzip -o $dout/$genome.faa.gz \
    $dout/$genome.sorted.gff
    
  # remove intermediate files
  rm $dout/$genome.fna*
  rm $dout/$genome.sorted.gff
    
done