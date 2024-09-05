#!/usr/bin/env Rscript

# This script parses the pangenomes inferred by various tools on various
# datasets into a nice gene table and into the OrthoBench format. In addition,
# the time/memory stats are converted to a table. 

# depencencies: R, tidyverse

library(tidyverse)
source("functions.R")

# define paths 
dio_lactos <- "../../results/scarap_pan/lactobacillales_genusreps"
dio_simpan <- "../../results/scarap_pan/simpan"
dio_tonkinhill <- "../../results/scarap_pan/tonkinhill"
dio_orthobench <- "../../results/scarap_pan/orthobench"
dio_parabench <- "../../results/scarap_pan/parabench"
dio_repseqs <- "../../results/scarap_pan/repseqs"

# compile and write resource consumption tables
message("compiling resource consumption tables")
dios <- c(dio_lactos, dio_simpan, dio_tonkinhill, dio_orthobench, dio_parabench, 
  dio_repseqs)
for (dio in dios) {
  paste0(dio, "/runs") %>%
    toolsubdirs() %>%
    read_stats() %>%
    write_csv(paste0(dio, "/resources.csv"))
}

# compile and write pangenome tables
message("compiling pangenome tables")
for (dio in dios) {
  paste0(dio, "/runs") %>%
    toolsubdirs() %>%
    compile_pangenomes(has_genomes = "scarap_fh") %>%
    write_csv(paste0(dio, "/pangenomes.csv.gz"))
}

# convert OrthoBench & ParaBench pangenomes to OrthoBench format
message("converting orthobench pangenomes to orthobench format")
pangenomes_to_orthobench(
  paste0(dio_orthobench, "/pangenomes.csv.gz"), 
  paste0(dio_orthobench, "/orthobench_formatted")
)
message("converting parabench pangenomes to orthobench format")
pangenomes_to_orthobench(
  paste0(dio_parabench, "/pangenomes.csv.gz"), 
  paste0(dio_parabench, "/orthobench_formatted")
)
