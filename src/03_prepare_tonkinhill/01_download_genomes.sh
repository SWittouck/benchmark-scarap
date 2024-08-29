# This script downloads some simulated genomes used in the benchmarking of the
# Panaroo pangenome tool (Tonkin-Hill et al., 2020). 

url=https://zenodo.org/records/3599800/files/sim_gr_1e-11_lr_1e-12_mu_1e-15_rep1_fragmented.tar.gz?download=1
dout=../../data/tonkinhill

# create output folder
[ -d $dout ] || mkdir $dout  

# download dataset
wget $url -O $dout/sim_rep1_fragmented.tar.gz

# unpack archive
tar xzf $dout/sim_rep1_fragmented.tar.gz -C $dout
mv $dout/sim_gr_1e-11_lr_1e-12_mu_1e-15_rep1_fragmented $dout/sim_rep1_fragmented

# move gffs to single folder
mkdir $dout/sim_rep1_fragmented/pgffs
mv $dout/sim_rep1_fragmented/prokka_art_assem/*/*.gff $dout/sim_rep1_fragmented/pgffs

# compress gffs
gzip $dout/sim_rep1_fragmented/pgffs/*.gff

# rename genomes 
for fin_gff in $dout/sim_rep1_fragmented/pgffs/*.gff.gz ; do 
  mv $fin_gff ${fin_gff/pan_sim_gr_1e-11_lr_1e-12_mu_1e-15_iso_/genome}
done

# remove unnecessary files
rm -r $dout/sim_rep1_fragmented/prokka_art_assem
rm $dout/sim_rep1_fragmented.tar.gz
