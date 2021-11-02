#!/usr/bin/env bash 

cd ../results
tar czf benchmark_scarap_v1.tar.gz \
  README.md \
  lactobacillales/pangenomes.csv \
  lactobacillales/times.csv \
  qfo2018_bacteria/pangenomes.csv \
  qfo2018_bacteria/times.csv