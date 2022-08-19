#!/usr/bin/env Rscript

# This script will select GenBank accession numbers of genomes of the species
# Lactiplantibacillus plantarum. 

# dependencies: R v3.6.1, tidyverse v1.2.1

library(tidyverse)

# define paths
url_gtdb <- "https://data.ace.uq.edu.au/public/gtdb/data/releases/release89/89.0/bac120_metadata_r89.tsv"
dout <- "../../data/lplantarum"

# define derived paths
fout_metadata <- paste0(dout, "/bac120_metadata_r89.tsv")
fout_accessions <- paste0(dout, "/accessions.txt")

# create output folder
if (! dir.exists(dout)) dir.create(dout)

# download genome metadata file from the GTDB
if (! file.exists(fout_metadata)) {
  download.file(url_gtdb, destfile = fout_metadata)
}

# read GTDB genomes and select Lactiplantibacillus plantarum genomes
genomes <- 
  read_tsv(fout_metadata) %>%
  mutate(gtdb_species = str_extract(gtdb_taxonomy, "s__[a-zA-Z_ ]+")) %>%
  filter(gtdb_species == "s__Lactobacillus_F plantarum") %>%
  filter(ncbi_genbank_assembly_accession != "none")

# write assembly accessions
genomes %>%
  select(genome = ncbi_genbank_assembly_accession) %>%
  write_tsv(fout_accessions, col_names = F)

# remove large file with raw genome metadata
file.remove(fout_metadata)