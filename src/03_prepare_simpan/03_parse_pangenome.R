#!/usr/bin/env Rscript

# This script parses a SimPan reference genome. 

# dependencies: R, tidyverse

library(tidyverse)

fin_pan <- "../../results/simpan/genome.gene.content.tsv"
fout_pan <- "../../results/simpan/reference_pangenome.tsv"

# read pangenome 
pan_raw <- read_tsv(fin_pan, col_names = T, col_types = cols(.default = "c"))

# convert pangenome to scarap format 
pan <- 
  pan_raw %>%
  rename(gene = `#ID`) %>%
  pivot_longer(- gene, names_to = "genome", values_to = "orthogroup") %>%
  mutate(gene = str_c("G", genome, gene, sep = "_")) %>%
  mutate(genome = str_c("genome", genome, sep = "_")) %>%
  filter(orthogroup != "-")

# write pangenome
pan %>% write_tsv(fout_pan, col_names = F)