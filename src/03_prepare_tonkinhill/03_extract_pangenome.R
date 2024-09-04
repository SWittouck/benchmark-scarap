#!/usr/bin/env Rscript

# This script extracts the reference pangenome from the tonkinhill simulated
# genomes. 

# dependencies: R, tidyverse

library(tidyverse)

din_gffs <- "../../data/tonkinhill/sim_rep1_fragmented/pgffs/"
fout_pan <- "../../results/tonkinhill/sim_rep1_fragmented/reference_pangenome.tsv"

# extract reference pangenome from gff files
pan <- 
  list.files(din_gffs, full.names = T) %>%
  map2(str_extract(., "[^/]+(?=.gff)"), function(path, genome) {
    message(paste0("extracting reference orthogroups from ", genome))
    path %>%
      read_lines() %>%
      {.[1:which(str_detect(., "^##FASTA"))]} %>%
      {.[! str_detect(., "^#")]} %>%
      tibble(all = .) %>%
      separate(all, into = str_c("X", 1:9), sep = "\t") %>%
      select(feature = X3, attributes = X9) %>%
      filter(feature == "CDS") %>%
      transmute(
        gene = str_extract(attributes, "(?<=ID=)[^;]+"),
        genome = {{genome}},
        orthogroup = str_extract(attributes, "(?<=prokka_DB.fasta:)[^;]+")
      )
  }) %>%
  reduce(.f = bind_rows)

# write pangenome
pan %>% write_tsv(fout_pan, col_names = F)
