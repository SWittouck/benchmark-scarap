#!/usr/bin/env Rscript

# This script parses the pangenomes inferred by various tools into a nice gene
# table.

# depencencies: tidyverse v1.3.0

library(tidyverse)
source("./parse_pangenomes_functions.R")

# define paths 
din_lacto <- "../results/lactobacillales/benchmarks"
din_bact <- "../results/qfo2018_bacteria/benchmarks"
dout <- "../results"

# create output folder if it doesn't exist
if (! dir.exists(dout)) dir.create(dout)

# make lists of results folders of tools
dins_lacto <- 
  list(
    "orthofinder_blast" = "/orthofinder_blast", 
    "sonicparanoid_sens" = "/sonicparanoid_sensitive", 
    "scarap_S" = "/scarap_S", 
    "scarap_H" = "/scarap_H", 
    "scarap_FH" = "/scarap_FH", 
    "scarap_FT" = "/scarap_FT"
  ) %>%
  map(~ paste0(din_lacto, .))
dins_bact <- 
  list(
    "orthofinder_blast" = "/orthofinder_blast", 
    "sonicparanoid_sens" = "/sonicparanoid_sensitive", 
    "scarap_FH" = "/scarap_FH"
  ) %>%
  map(~ paste0(din_bact, .))

# merge the pangenomes into a large gene table
pans_lacto <- compile_pangenomes(dins_lacto, has_genomes = "scarap_FH")
pans_bact <- compile_pangenomes(dins_bact, has_genomes = "scarap_FH")

# write the gene table
pans_lacto %>% write_csv(paste0(dout, "/lactobacillales/pangenomes.csv"))
pans_bact %>% write_csv(paste0(dout, "/qfo2018_bacteria/pangenomes.csv"))

# read the time used by each tool
times_lacto <- compile_times(dins_lacto)
times_bact <- compile_times(dins_bact)

# write the times
times_lacto %>% write_csv(paste0(dout, "/lactobacillales/times.csv"))
times_bact %>% write_csv(paste0(dout, "/qfo2018_bacteria/times.csv"))
