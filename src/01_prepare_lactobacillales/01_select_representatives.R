#!/usr/bin/env Rscript

# This script will select GenBank accession numbers of species and genus 
# representatives of the order Lactobacillales. The best-quality genome per 
# species/genus is chosen as representative. As a consequence, the genus 
# representatives are a subset of the species representatives. 

# dependencies: R V3.6.1, tidyverse v1.2.1

library(tidyverse)

# define paths
url_gtdb <- "https://data.ace.uq.edu.au/public/gtdb/data/releases/release89/89.0/bac120_metadata_r89.tsv"
fout_metadata <- "../../data/lactobacillales/bac120_metadata_r89.tsv"
fout_accessions_species <- "../../data/lactobacillales/accessions_speciesreps.tsv"
fout_accessions_genera <- "../../data/lactobacillales/accessions_genusreps.tsv"

if (! file.exists(fout_metadata)) {
  download.file(url_gtdb, destfile = fout_metadata)
}

# read GTDB genomes and select Lactobacillales
genomes <- 
  read_tsv(fout_metadata) %>%
  mutate(
    gtdb_order = str_extract(gtdb_taxonomy, "o__[a-zA-Z_]+"),
    gtdb_genus = str_extract(gtdb_taxonomy, "g__[a-zA-Z_]+"),
    gtdb_species = str_extract(gtdb_taxonomy, "s__[a-zA-Z_ ]+")
  ) %>%
  filter(gtdb_order == "o__Lactobacillales") %>%
  filter(ncbi_genbank_assembly_accession != "none") %>%
  mutate(checkm_quality = checkm_completeness - checkm_contamination)

# select species representatives and write
genomes %>%
  group_by(gtdb_species, gtdb_genus) %>%
  arrange(desc(checkm_quality)) %>%
  slice(1) %>%
  ungroup() %>%
  select(genome = ncbi_genbank_assembly_accession, gtdb_species, gtdb_genus) %>%
  write_tsv(fout_accessions_species, col_names = F)

# select genus representatives and write
genomes %>%
  group_by(gtdb_genus) %>%
  arrange(desc(checkm_quality)) %>%
  slice(1) %>%
  ungroup() %>%
  select(genome = ncbi_genbank_assembly_accession, gtdb_genus) %>%
  write_tsv(fout_accessions_genera, col_names = F)

file.remove(fout_metadata)