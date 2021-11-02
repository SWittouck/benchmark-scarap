#!/usr/bin/env Rscript 

# The goal of this script is to quickly explore the SCARAP results on the
# bacterial dataset of Quest for Orthologs (2018). 

library(tidyverse)

fin_pan <- "results/qfo2018_bacteria/benchmarks/SCARAP-FH/pangenome.tsv"

colnames <- c("gene", "genome", "orthogroup")
pan <- read_tsv(fin_pan, col_types = cols(), col_names = colnames)

pan %>%
  count(genome, orthogroup) %>%
  group_by(orthogroup) %>%
  summarize(n_single_copy = sum(n == 1), .groups = "drop") %>%
  count(n_single_copy, name = "n_orthogroups") %>%
  arrange(desc(n_single_copy))
