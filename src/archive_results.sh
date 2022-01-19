#!/usr/bin/env bash 

cd ../results
tar czf benchmark_scarap_v2-beta.tar.gz \
  README.md \
  scarap_pan/orthobench/pangenomes.csv \
  scarap_pan/orthobench/resources.csv \
  scarap_pan/orthobench/benchmarks.csv \
  scarap_pan/parabench/pangenomes.csv \
  scarap_pan/parabench/resources.csv \
  scarap_pan/parabench/benchmarks.csv \
  scarap_pan/lactobacillales_genusreps/pangenomes.csv \
  scarap_pan/lactobacillales_genusreps/resources.csv \
  scarap_pan/lactobacillales_speciesreps/scarap_fh/pangenome.tsv \
  scarap_pan/lactobacillales_speciesreps/scarap_fh/stats.txt \
  scarap_sample/lplantarum/corefull_mean/identities.tsv \
  scarap_sample/lplantarum/corefull_mean/seeds.txt \
  scarap_sample/lplantarum/core100_mean/identities.tsv \
  scarap_sample/lplantarum/core100_mean/seeds.txt \
  scarap_sample/lplantarum/corefull_mean90/identities.tsv \
  scarap_sample/lplantarum/corefull_mean90/seeds.txt \
  scarap_sample/lplantarum/core100_mean90/identities.tsv \
  scarap_sample/lplantarum/core100_mean90/seeds.txt
