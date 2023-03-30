#!/usr/bin/env Rscript

# This script selects GenBank accession numbers of genomes of the genus
# Lactiplantibacillus. 

# depencencies: R v4.1.2, tidyverse v2.0.0

library(tidyverse)

# define paths
url_gtdb <- "https://data.gtdb.ecogenomic.org/releases/release207/207.0/bac120_metadata_r207.tar.gz" # GTDB07
dout <- "../../data/lactiplantibacillus"

# define derived paths
fout_metadata_raw <- paste0(dout, "/bac120_metadata_r207.tar.gz")
fout_metadata <- paste0(dout, "/bac120_metadata_r207.tsv")
fout_accessions <- paste0(dout, "/accessions.txt")

# create output folder
if (! dir.exists(dout)) dir.create(dout)

# download genome metadata file from the GTDB and untar
if (! file.exists(fout_metadata_raw)) {
  download.file(url_gtdb, destfile = fout_metadata_raw)
}
if (! file.exists(fout_metadata)) {
  untar(fout_metadata_raw, exdir = dout)
}

# read GTDB genomes and select Lactiplantibacillus genomes
ranks <- c(
  "gtdb_domain", "gtdb_phylum", "gtdb_class", "gtdb_order", "gtdb_family", 
  "gtdb_genus", "gtdb_species"
)
genomes <- 
  read_tsv(fout_metadata, col_types = cols()) %>%
  separate(gtdb_taxonomy, into = ranks, sep = ";") %>%
  filter(gtdb_genus == "g__Lactiplantibacillus") %>%
  filter(ncbi_genbank_assembly_accession != "none")

# write assembly accessions
genomes %>%
  select(genome = ncbi_genbank_assembly_accession) %>%
  write_tsv(fout_accessions, col_names = F)

# remove large file with raw genome metadata
if (file.exists(fout_accessions)) {
  file.remove(fout_metadata_raw)
  file.remove(fout_metadata)
}
