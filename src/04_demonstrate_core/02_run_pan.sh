# This script infers the pangenome of a set of Lactiplantibacillus genomes to be 
# able to compare the result of the core module to the full pangenome. 

# dependencies: SCARAP v0.4.0

din_faas=../../results/lactiplantibacillus/faas
dout=../../results/scarap_core/lactiplantibacillus

threads=16

# create output subfolder
[ -d $dout/pan ] || mkdir $dout/pan

# infer pangenome (-c flag necessary because of time tool)
/usr/bin/time -v -o $dout/pan/stats.txt scarap pan \
  $din_faas $dout/pan -t $threads -c