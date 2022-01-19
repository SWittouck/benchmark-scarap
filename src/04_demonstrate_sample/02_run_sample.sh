# This script performs maximum novelty sampling on a set of L. plantarum 
# genomes; first given then full core genome, then given a set of 100 core 
# genes.

# dependencies: SCARAP commit b096905

din_ffns=../../results/lplantarum/ffns
fin_corefull=../../results/scarap_core/lplantarum/corefull/coregenome.tsv
fin_core100=../../results/scarap_core/lplantarum/core100/coregenome.tsv
dout=../../results/scarap_sample/lplantarum

threads=16

# create output folder and its parent
[ -d $(dirname $dout) ] || mkdir $(dirname $dout)
[ -d $dout ] || mkdir $dout 

# create output subfolders
[ -d $dout/corefull_mean ] || mkdir $dout/corefull_mean
[ -d $dout/core100_mean ] || mkdir $dout/core100_mean
[ -d $dout/corefull_mean90 ] || mkdir $dout/corefull_mean90
[ -d $dout/core100_mean90 ] || mkdir $dout/core100_mean90

# perform maximum novelty sampling
# /usr/bin/time -v -o $dout/corefull_mean/stats.txt scarap sample \
#   $din_ffns $fin_corefull $dout/corefull_mean -t $threads -c
# /usr/bin/time -v -o $dout/core100_mean/stats.txt scarap sample \
#   $din_ffns $fin_core100 $dout/core100_mean -t $threads -c
/usr/bin/time -v -o $dout/corefull_mean90/stats.txt scarap sample \
  $din_ffns $fin_corefull $dout/corefull_mean90 -t $threads -c --method mean90
/usr/bin/time -v -o $dout/core100_mean90/stats.txt scarap sample \
  $din_ffns $fin_core100 $dout/core100_mean90 -t $threads -c --method mean90