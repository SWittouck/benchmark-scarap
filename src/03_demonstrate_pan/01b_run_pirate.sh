# This script runs PIRATE on the prokaryotic benchmark genome datasets. 
# 
# dependencies: PIRATE v1.0.5

din_pgffs=../../results/lactobacillales/genusreps/pgffs
dout_pan=../../results/scarap_pan/lactobacillales_genusreps/tools/pirate

threads=16

# create output folder and subfolders
[ -d $dout_pan ] || mkdir $dout_pan 

# unzip gff files
gunzip $din_pgffs/*.gff.gz

# run and time pirate
/usr/bin/time -v -o $dout_pan/stats.txt \
  PIRATE -i $din_pgffs -o $dout_pan -t $threads

# rezip gff files
gzip $din_pgffs/*.gff
