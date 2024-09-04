#!/usr/bin/env Rscript

# This script processes the pangenome benchmarks on the tonkinhill dataset. 

# dependencies: R v4.1.2, tidyverse v2.0.0

library(tidyverse)
source("functions.R")

din_gffs <- "../../data/tonkinhill/sim_rep1_fragmented/pgffs/"
fin_ref <- "../../results/tonkinhill/sim_rep1_fragmented/reference_pangenome.tsv"
fin_pans <- "../../results/scarap_pan/tonkinhill/pangenomes.csv.gz"
fout_benchmarks <- "../../results/scarap_pan/tonkinhill/benchmarks.csv"

# read reference pangenome
colnames <- c("gene", "genome", "orthogroup")
pan_ref <- 
  read_tsv(fin_ref, col_names = colnames, col_types = cols(.default = "c"))

# read pangenomes 
pans <- read_csv(fin_pans, col_types = cols(.default = "c"))

# add reference pangenome
pans <- pans %>% left_join(pan_ref, by = c("gene", "genome"))

# evaluate pangenomes 
tools <- pans %>% precrec_table(ref_pangenome = orthogroup)
  
# write evaluations
tools %>% write_csv(fout_benchmarks)
