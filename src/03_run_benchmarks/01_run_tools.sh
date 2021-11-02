#!/usr/bin/env bash

# The goal of this script is to run a set of pangenome tools on a set of 
# different test databases containing genomes (faa files). 

# dependencies: SCARAP fe2ae66

din_orthobench=../../data/OrthoBench_v1.1/Input # *.fa.gz
din_parabench=../../data/paraBench/data/proteomes # *.fasta.gz
din_lactos=../../results/dataprep/lactobacillales/genes/faas # *.faa.gz
dout_root=../../results/benchmarks

threads=16

# BENCHMARKING FUNCTION PER TOOL

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
    rm -r $dout_loc/alignments
    rm -r $dout_loc/mmseqs2_databases
  fi 
}

benchmark_broccoli() {
  din_loc=$1; dout_loc=$2; mode=$3
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

# BENCHMARKING CODE

dins=( $din_orthobench $din_parabench $din_lactos )
datasets=( orthobench parabench lactobacillales )

for i in ${!dins[@]} ; do

  din=${dins[i]}
  dout=$dout_root/${datasets[i]}/tools

  # create output folder
  [ -d $dout ] || mkdir -p $dout

  # unzip genomes
  gunzip $din/*.gz

  # run SCARAP FH
  benchmark_scarap $din $dout/scarap_fh FH
  # run SCARAP S
  benchmark_scarap $din $dout/scarap_s S
  # run OrthoFinder - BLAST
  benchmark_orthofinder $din $dout/orthofinder_blast blast
  # run OrthoFinder - MMseqs2
  benchmark_orthofinder $din $dout/orthofinder_mmseqs mmseqs
  # run SonicParanoid - sensitive
  benchmark_sonicparanoid $din $dout/sonicparanoid_sensitive sensitive
  # run SonicParanoid - fast
  benchmark_sonicparanoid $din $dout/sonicparanoid_fast fast
  # run Broccoli
  benchmark_broccoli $din $dout/broccoli

  # rezip genomes
  gzip $din/*

done
