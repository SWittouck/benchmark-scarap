#!/usr/bin/env Rscript

# dependencies: tidyverse v1.2.1

library(tidyverse)

url_gtdb <- "https://data.ace.uq.edu.au/public/gtdb/data/releases/release89/89.0/bac120_metadata_r89.tsv"
fout_metadata <- "../../data/bac120_metadata_r89.tsv"
fout_accessions <- "../../data/genomes_lactobacillales.tsv"

if (! file.exists(fout_metadata)) {
  download.file(url_gtdb, destfile = fout_metadata)
}
  
genomes_gtdb <- read_tsv(fout_metadata)

genomes_gtdb %>%
  mutate(
    gtdb_order = str_extract(gtdb_taxonomy, "o__[a-zA-Z_]+"),
    gtdb_genus = str_extract(gtdb_taxonomy, "g__[a-zA-Z_]+")
  ) %>%
  filter(gtdb_order == "o__Lactobacillales") %>%
  filter(ncbi_genbank_assembly_accession != "none") %>%
  group_by(gtdb_genus) %>%
  mutate(checkm_quality = checkm_completeness - checkm_contamination) %>%
  arrange(desc(checkm_quality)) %>%
  slice(1) %>%
  ungroup() %>%
  select(genome = ncbi_genbank_assembly_accession, gtdb_genus) %>%
  write_tsv(fout_accessions, col_names = F)

file.remove(fout_metadata)