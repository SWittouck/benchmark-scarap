# This script processes the pangenome benchmarks on the tonkinhill dataset. 

# dependencies: R v4.1.2, tidyverse v2.0.0

library(tidyverse)
source("functions.R")

din_gffs <- "../../data/tonkinhill/sim_rep1_fragmented/pgffs/"
fin_pans <- "../../results/scarap_pan/tonkinhill/pangenomes.csv.gz"
fout_tonkinhill <- "../../results/scarap_pan/tonkinhill/benchmarks.csv"

# extract reference pangenome from gff files
colnames <- c(
  "seqid", "source", "type", "start", "end", "score", "strand", "phase", 
  "attributes"
)
pan_ref <- 
  list.files(din_gffs, full.names = T) %>%
  map2(str_extract(., "[^/]+(?=.gff.gz)"), function(path, genome) {
    path %>%
      read_tsv(
        col_types = cols(.default = "c"), comment = "#", col_names = colnames
      ) %>%
      mutate(genome = {{genome}}) %>%
      filter(type == "CDS") %>%
      mutate(
        gene = str_extract(attributes, "(?<=ID=)[^;]+"),
        orthogroup = str_extract(attributes, "(?<=prokka_DB.fasta:)[^;]+")
      ) %>%
      mutate() %>%
      select(gene, genome, orthogroup) 
  }) %>%
  reduce(bind_rows) 

# read pangenomes 
pans <- read_csv(fin_pans, col_types = cols())

# add reference pangenome
pans <- pans %>% left_join(pan_ref, by = c("gene", "genome"))

# evaluate pangenomes 
tools <- pans %>% precrec_table(ref_pangenome = orthogroup)
  
# write evaluations
tools %>% write_csv(fout_tonkinhill)
