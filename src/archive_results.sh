#!/usr/bin/env bash 

cd ../results
tar czf benchmark_scarap_v4.tar.gz \
  README.md \
  scarap_pan/*/benchmarks.csv \
  scarap_pan/*/resources.csv \
  scarap_pan/*/statistics.csv \
  scarap_pan/lactobacillales_genusreps/pangenomes.csv.gz \
  scarap_pan/simpan/pangenomes.csv.gz \
  scarap_pan/tonkinhill/pangenomes.csv.gz \
  scarap_pan/orthobench/pangenomes.csv.gz \
  scarap_pan/parabench/pangenomes.csv.gz \
  scarap_core/lactiplantibacillus/corefull/genes.tsv \
  scarap_core/lactiplantibacillus/core100/genes.tsv \
  scarap_core/lactiplantibacillus/pan/pangenome.tsv \
  scarap_core/lactiplantibacillus/*/stats.txt \
  scarap_sample/lactiplantibacillus/*/identities.tsv \
  scarap_sample/lactiplantibacillus/*/seeds.txt \
  scarap_sample/lactiplantibacillus/*/stats.txt \
  scarap_sample/lactiplantibacillus/tree/lactiplantibacillus.treefile
