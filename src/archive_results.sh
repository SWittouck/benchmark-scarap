#!/usr/bin/env bash 

cd ../results/scarap_pan
tar czf benchmark_scarap_v2-beta.tar.gz \
  README.md \
  orthobench/pangenomes.csv \
  orthobench/resources.csv \
  orthobench/benchmarks.csv \
  parabench/pangenomes.csv \
  parabench/resources.csv \
  parabench/benchmarks.csv \
  lactobacillales/pangenomes.csv \
  lactobacillales/resources.csv
mv benchmark_scarap_v2-beta.tar.gz ../
