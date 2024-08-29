# This script infers the core genome of a set of L. plantarum genomes; first the
# full core genome, then a set of 100 core genes. 

# dependencies: SCARAP v0.4.0

din_faas=../../results/lactiplantibacillus/faas
dout=../../results/scarap_core/lactiplantibacillus

threads=16

# create output folder and its parent
[ -d $(dirname $dout) ] || mkdir $(dirname $dout)
[ -d $dout ] || mkdir $dout 

# create output subfolders
[ -d $dout/corefull ] || mkdir $dout/corefull
[ -d $dout/core100 ] || mkdir $dout/core100

# infer core genome (-c flag necessary because of time tool)
/usr/bin/time -v -o $dout/corefull/stats.txt scarap core \
  $din_faas $dout/corefull -t $threads -c
/usr/bin/time -v -o $dout/core100/stats.txt scarap core \
  $din_faas $dout/core100 -t $threads -c --max-core-genes 100
