# This script infers the core genome of a set of L. plantarum genomes; first the
# full core genome, then a set of 100 core genes. 

# dependencies: SCARAP commit 8d2ead2

din_faas=../../results/lplantarum/faas
dout=../../results/scarap_core/lplantarum

threads=16

# create output folder and its parent
[ -d $(dirname $dout) ] || mkdir $(dirname $dout)
[ -d $dout ] || mkdir $dout 

# create output subfolders
[ -d $dout/corefull ] || mkdir $dout/corefull
[ -d $dout/core100 ] || mkdir $dout/core100

# infer core genome
/usr/bin/time -v -o $dout/corefull/stats.txt scarap core \
  $din_faas $dout/corefull -t $threads -c
/usr/bin/time -v -o $dout/core100/stats.txt scarap core \
  $din_faas $dout/core100 -t $threads -c --max_cores 100