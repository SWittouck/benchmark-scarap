#!/usr/bin/env Rscript

# This script selects GenBank accession numbers of species and genus
# representatives of the order Lactobacillales. The best-quality genome per
# species/genus is chosen as representative. As a consequence, the genus
# representatives are a subset of the species representatives.

# depencencies: R v4.1.2, tidyverse v2.0.0

library(tidyverse)

# define paths
url_gtdb <- "https://data.gtdb.ecogenomic.org/releases/release207/207.0/bac120_metadata_r207.tar.gz" # GTDB07
dout <- "../../data/lactobacillales"

# define derived paths
fout_metadata_raw <- paste0(dout, "/bac120_metadata_r207.tar.gz")
fout_metadata <- paste0(dout, "/bac120_metadata_r207.tsv")
fout_accessions_species <- paste0(dout, "/accessions_speciesreps.tsv")
fout_accessions_genera <- paste0(dout, "/accessions_genusreps.tsv")

# create output folder
if (! dir.exists(dout)) dir.create(dout)

# download genome metadata file from the GTDB and untar
if (! file.exists(fout_metadata_raw)) {
  download.file(url_gtdb, destfile = fout_metadata_raw)
}
if (! file.exists(fout_metadata)) {
  untar(fout_metadata_raw, exdir = dout)
}

# read GTDB genomes and select Lactobacillales
ranks <- c(
  "gtdb_domain", "gtdb_phylum", "gtdb_class", "gtdb_order", "gtdb_family", 
  "gtdb_genus", "gtdb_species"
)
genomes <-
  read_tsv(fout_metadata, col_types = cols()) %>%
  separate(gtdb_taxonomy, into = ranks, sep = ";") %>%
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

# remove large file with raw genome metadata
if (file.exists(fout_accession_genera)) {
  file.remove(fout_metadata_raw)
  file.remove(fout_metadata)
}