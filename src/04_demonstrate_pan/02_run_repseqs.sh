#!/usr/bin/env bash 

# This script runs SCARAP with various settings for min-reps, max-reps and 
# max-align. 

# dependencies: SCARAP

din=../../results/lactobacillales/speciesreps/faas
dout=../../results/scarap_pan/repseqs

threads=16

[ -d $dout ] || mkdir $dout
[ -d $dout/runs ] || mkdir $dout/runs

benchmark_scarap() {

  _min_reps=$1
  _max_reps_p=$2
  _max_align_f=$3

  _max_reps=$(( (100 + $_max_reps_p) * $_min_reps / 100 ))
  _max_align=$(( $_max_reps * $_max_align_f ))
  _dout=$dout/runs/minreps${_min_reps}_maxreps${_max_reps_p}p_maxalign${_max_align_f}f

  [ -d $_dout ] && return
  mkdir $_dout

  /usr/bin/time -v -o $_dout/stats.txt scarap pan $din $_dout \
    --min-reps $_min_reps --max-reps $_max_reps --max-align $_max_align \
    --threads $threads -c

}

# evaluate min-reps setting
max_reps_p=0
max_align_f=1
for min_reps in 2 4 8 16 32 64 128 ; do
    echo min-reps: $min_reps
    benchmark_scarap $min_reps $max_reps_p $max_align_f
done

# evaluate max-reps setting
min_reps=32
max_align_f=1
for max_reps_p in 25 50 75 100 ; do
    echo max-reps: $max_reps_p percent
    benchmark_scarap $min_reps $max_reps_p $max_align_f
done

# evaluate max-align setting
min_reps=32
max_reps_p=0
for max_align_f in 2 4 8 16 32 ; do
    echo max-align: factor $max_align_f
    benchmark_scarap $min_reps $max_reps_p $max_align_f
done
