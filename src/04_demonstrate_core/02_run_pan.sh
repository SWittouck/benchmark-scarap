# This script infers the pangenome of a set of L. plantarum genomes to be able 
# to compare the result of the core module to the full pangenome. 

# dependencies: SCARAP commit 8d2ead2

din_faas=../../results/lplantarum/faas
dout=../../results/scarap_core/lplantarum

threads=32

# create output subfolder
[ -d $dout/pan ] || mkdir $dout/pan

# infer pangenome
/usr/bin/time -v -o $dout/pan/stats.txt scarap pan \
  $din_faas $dout/pan -t $threads -c