#!/usr/bin/env bash 

cd ../results
tar czf benchmark_scarap_v4.tar.gz \
  README.md \
  scarap_pan/lactobacillales_genusreps/pangenomes.csv.gz \
  scarap_pan/lactobacillales_genusreps/resources.csv \
  scarap_pan/lactobacillales_speciesreps/scarap_fh/pangenome.tsv \
  scarap_pan/lactobacillales_speciesreps/scarap_fh/stats.txt \
  scarap_pan/orthobench/pangenomes.csv.gz \
  scarap_pan/orthobench/resources.csv \
  scarap_pan/orthobench/benchmarks.csv \
  scarap_pan/parabench/pangenomes.csv.gz \
  scarap_pan/parabench/resources.csv \
  scarap_pan/parabench/benchmarks.csv \
  scarap_pan/tonkinhill/pangenomes.csv.gz \
  scarap_pan/tonkinhill/resources.csv \
  scarap_pan/tonkinhill/benchmarks.csv \
  scarap_core/lactiplantibacillus/corefull/genes.tsv \
  scarap_core/lactiplantibacillus/core100/genes.tsv \
  scarap_core/lactiplantibacillus/pan/pangenome.tsv \
  scarap_sample/lactiplantibacillus/corefull_mean/identities.tsv \
  scarap_sample/lactiplantibacillus/corefull_mean/seeds.txt \
  scarap_sample/lactiplantibacillus/core100_mean/identities.tsv \
  scarap_sample/lactiplantibacillus/core100_mean/seeds.txt \
  scarap_sample/lactiplantibacillus/corefull_mean90/identities.tsv \
  scarap_sample/lactiplantibacillus/corefull_mean90/seeds.txt \
  scarap_sample/lactiplantibacillus/core100_mean90/identities.tsv \
  scarap_sample/lactiplantibacillus/core100_mean90/seeds.txt \
  scarap_sample/lactiplantibacillus/tree/lactiplantibacillus.treefile
  