# This script infers a strain phylogeny of the genus Lactiplantibacillus, using
# 100 core genes. 

# dependencies: SCARAP v0.4.0, IQ-TREE v1.6.12

din_faas=../../results/lactiplantibacillus/faas
din_ffns=../../results/lactiplantibacillus/ffns
fin_core100=../../results/scarap_core/lactiplantibacillus/core100/genes.tsv
dout=../../results/scarap_sample/lactiplantibacillus

threads=16

# create output subfolders
[ -d $dout/supermatrix ] || mkdir $dout/supermatrix
[ -d $dout/tree ] || mkdir $dout/tree

# infer a supermatrix from the 100 core genes 
scarap concat $din_faas $fin_core100 $dout/supermatrix --ffn-files $din_ffns \
  --threads $threads

# infer the tree 
iqtree \
  -s $dout/supermatrix/supermatrix_nucs.fasta \
  -pre $dout/tree/lactiplantibacillus \
  -m GTR+G4 \
  -nt $threads
