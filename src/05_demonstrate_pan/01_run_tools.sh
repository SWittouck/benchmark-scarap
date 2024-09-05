#!/usr/bin/env bash

# This script runs a set of pangenome tools on a set of test datasets; taking
# as input either prokka-style gffs ("pgffs") or proteomes ("faas"). 

# dependencies: SCARAP, OrthoFinder, SonicParanoid, broccoli, PIRATE

# locations of pgffs
din_lacto_gffs=../../results/lactobacillales/genusreps/pgffs
din_simpan_gffs=../../results/simpan/pgffs
din_tonkinhill_gffs=../../data/tonkinhill/sim_rep1_fragmented/pgffs

# locations of faas
din_lacto_faas=../../results/lactobacillales/genusreps/faas # *.faa.gz
din_simpan_faas=../../results/simpan/faas # *.faa.gz
din_tonkinhill_faas=../../results/tonkinhill/sim_rep1_fragmented/faas # *.faa.gz
din_orthobench_faas=../../data/orthobench/OrthoBench_v1.1/Input # *.fa.gz
din_parabench_faas=../../data/parabench/paraBench/data/proteomes # *.fasta.gz

# output folder
dout_root=../../results/scarap_pan

# input/output for lacto species pangenome
din_lacto_species_faas=../../results/lactobacillales/speciesreps/faas 
dout_lacto_species=../../results/scarap_pan/lactobacillales_speciesreps/scarap_fh

threads=16

#######################
# Benchmark functions #
#######################

benchmark_scarap() {
  din_loc=$1; dout_loc=$2; mode=$3
  if [ ! -d $dout_loc ] ; then
    mkdir $dout_loc
    echo MADE DIR $dout_loc
    /usr/bin/time -v -o $dout_loc/stats.txt scarap pan $din_loc $dout_loc -c \
      --method $mode --threads $threads
  fi 
}

benchmark_orthofinder() {
  din_loc=$1; dout_loc=$2; mode=$3
  if [ ! -d $dout_loc ] ; then
    mkdir $dout_loc
    echo MADE DIR $dout_loc
    cp $din_loc/* $dout_loc
    /usr/bin/time -v -o $dout_loc/stats.txt orthofinder -og -S $mode \
      -t $threads -f $dout_loc
    rm $dout_loc/*.{fasta,fa,faa}
    rm -r $dout_loc/OrthoFinder/Results_*/WorkingDirectory
  fi 
}

benchmark_sonicparanoid() {
  din_loc=$1; dout_loc=$2; mode=$3
  if [ ! -d $dout_loc ] ; then
    mkdir $dout_loc
    echo MADE DIR $dout_loc
    /usr/bin/time -v -o $dout_loc/stats.txt sonicparanoid -i $din_loc \
      -o $dout_loc -m $mode -t $threads 2>&1 | tee $dout_loc/sonicparanoid.log
  fi 
}

benchmark_broccoli() {
  din_loc=$1; dout_loc=$2
  if [ ! -d $dout_loc ] ; then
    mkdir $dout_loc
    echo MADE DIR $dout_loc
    firstfile=$( ls $din_loc/*.{fasta,fa,faa} 2> /dev/null | head -1 )
    ext=${firstfile##*.}
    /usr/bin/time -v -o $dout_loc/stats.txt broccoli -dir $din_loc \
      -steps '1,2,3' -threads $threads -ext $ext
    mv ./dir_step3/orthologous_groups.txt $dout_loc
    rm -r ./dir_step1 ./dir_step2 ./dir_step3
  fi 
}

benchmark_pirate() {
  din_loc=$1; dout_loc=$2
  if [ ! -d $dout_loc ] ; then
    mkdir $dout_loc
    echo MADE DIR $dout_loc
    /usr/bin/time -v -o $dout_loc/stats.txt \
      PIRATE -i $din_loc -o $dout_loc -t $threads
    rm -r $dout_loc/pangenome_iterations
  fi 
}

########################
# Tools that need gffs #
########################

dins=( $din_lacto_gffs $din_simpan_gffs $din_tonkinhill_gffs )
datasets=( lactobacillales_genusreps simpan tonkinhill )

for i in ${!dins[@]} ; do

  din=${dins[i]}
  dout=$dout_root/${datasets[i]}/runs

  # create output folder
  [ -d $dout ] || mkdir -p $dout

  # unzip genomes
  gunzip $din/*.gz

  # run tools
  benchmark_pirate $din $dout/pirate

  # rezip genomes
  gzip $din/*

done

########################
# Tools that need faas #
########################

dins=( $din_lacto_faas $din_simpan_faas $din_tonkinhill_faas \
  $din_orthobench_faas $din_parabench_faas )
datasets=( lactobacillales_genusreps simpan tonkinhill orthobench parabench )

for i in ${!dins[@]} ; do

  din=${dins[i]}
  dout=$dout_root/${datasets[i]}/runs

  # create output folder
  [ -d $dout ] || mkdir -p $dout

  # unzip genomes
  gunzip $din/*.gz

  # run tools
  benchmark_scarap $din $dout/scarap_fh FH
  benchmark_scarap $din $dout/scarap_s S
  benchmark_orthofinder $din $dout/orthofinder_blast blast
  benchmark_orthofinder $din $dout/orthofinder_mmseqs mmseqs
  benchmark_sonicparanoid $din $dout/sonicparanoid_sensitive sensitive
  benchmark_sonicparanoid $din $dout/sonicparanoid_fast fast
  benchmark_broccoli $din $dout/broccoli

  # rezip genomes
  gzip $din/*

done

# run SCARAP FH on Lactobacillales species representatives
if [ ! -d $dout_lacto_species ] ; then
  scarap pan $din_lacto_species_faas $dout_lacto_species -t $threads
fi