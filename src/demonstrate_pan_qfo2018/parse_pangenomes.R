#!/usr/bin/env Rscript

# This script parses the pangenomes inferred by various tools on the QfO2018
# dataset into a nice gene table and puts the time consumptions into a table. 

# depencencies: tidyverse v1.3.0

library(tidyverse)
source("./parse_pangenomes_functions.R")

# define paths 
dio <- "../results/benchmarks/qfo2018_bacteria"

# make lists of results folders of tools
dins <- 
  list(
    "orthofinder_blast" = "/orthofinder_blast", 
    "sonicparanoid_sens" = "/sonicparanoid_sensitive", 
    "scarap_FH" = "/scarap_FH"
  ) %>%
  map(~ paste0(dio, .))

# merge the pangenomes into a large gene table
pans <- compile_pangenomes(dins, has_genomes = "scarap_FH")

# write the gene table
pans %>% write_csv(paste0(dio, "/pangenomes.csv"))

# read the time used by each tool
times <- compile_times(dins)

# write the times
times %>% write_csv(paste0(dio, "/times.csv"))
