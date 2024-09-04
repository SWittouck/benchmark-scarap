#!/usr/bin/env Rscript
# This script processes the pangenome benchmarks on the tonkinhill dataset. 

# dependencies: R v4.1.2, tidyverse v2.0.0

library(tidyverse)
source("functions.R")

din_gffs <- "../../data/tonkinhill/sim_rep1_fragmented/pgffs/"
fin_pans <- "../../results/scarap_pan/tonkinhill/pangenomes.csv.gz"
fout_tonkinhill <- "../../results/scarap_pan/tonkinhill/benchmarks.csv"

# extract reference pangenome from gff files
pan_ref <- 
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

# read pangenomes 
pans <- read_csv(fin_pans, col_types = cols())

# add reference pangenome
pans <- pans %>% left_join(pan_ref, by = c("gene", "genome"))

# evaluate pangenomes 
tools <- pans %>% precrec_table(ref_pangenome = orthogroup)
  
# write evaluations
tools %>% write_csv(fout_tonkinhill)
