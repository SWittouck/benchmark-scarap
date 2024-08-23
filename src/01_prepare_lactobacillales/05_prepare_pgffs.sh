#!/usr/bin/env bash

# This script prepares prokka-style gff files ("pgffs"), which are needed by
# some pangenome tools such as PIRATE. 

din_gffs=../../results/lactobacillales/genusreps/gffs
din_fnas=../../data/lactobacillales/genomes_ncbi 
dout_pgffs=../../results/lactobacillales/genusreps/pgffs

# create output folder
[ -d $dout_pgffs ] || mkdir $dout_pgffs

# create prokka-style gff files (for pirate)
for fin_gff in $din_gffs/*.gff.gz ; do

  # extract genome name from input gff filename
  genome=$(basename $fin_gff)
  genome=${genome%.gff.gz}
  
  # skip iteration if output gff file already exists
  if [[ -e $dout_lacto_pan/gffs/$genome.gff.gz ]] ; then continue ; fi
  echo $genome
  
  # construct path of fna file corresponding to gff file
  fin_fna=$din_fnas/$genome*.fna.gz
  
  # modify ID attribute of gff file to match gene identifies in faa file
  zcat $fin_gff | awk '{sub("ID=[^_]+_", "ID=" $1 "_")}1' \
    > $dout_pgffs/$genome.gff
  
  # add contig sequences to output gff file 
  echo '##FASTA' >> $dout_pgffs/$genome.gff
  gunzip $fin_fna
  cat ${fin_fna%.gz} | sed -E 's/>([^ ]+) .*/>\1/g' \
    >> $dout_pgffs/$genome.gff
  gzip ${fin_fna%.gz}
  
  # compress output gff file
  gzip $dout_pgffs/$genome.gff
  
done