#!/usr/bin/env Rscript 

# This script converts the SCARAP pangenome to a pairwise orthology format
# readable by the Quest for Orthologs benchmarking platform. 

library(tidyverse)

fin_pan <- "../../results/qfo2018_bacteria/benchmarks/scarap_FH/pangenome.tsv"
fout_genepairs <- "../../results/qfo2018_bacteria/benchmarks/scarap_FH/pangenome_genepairs.tsv"

colnames <- c("gene", "genome", "orthogroup")
pan <- read_tsv(fin_pan, col_types = cols(), col_names = colnames)

genepairs <-
  pan %>%
  mutate(gene = str_extract(gene, "(?<=\\|)[^|]+(?=\\|)")) %>%
  select(gene_1 = gene, orthogroup) %>%
  group_by(orthogroup) %>%
  mutate(gene_2 = list(gene_1)) %>%
  ungroup() %>%
  unnest(gene_2) %>%
  filter(gene_1 < gene_2) %>%
  select(- orthogroup) 

genepairs %>% write_tsv(fout_genepairs, col_names = F)