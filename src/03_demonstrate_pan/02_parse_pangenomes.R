#!/usr/bin/env Rscript

# This script parses the pangenomes inferred by various tools on various
# datasets into a nice gene table and into the OrthoBench format. In addition,
# the time/memory stats are converted to a table. 

# depencencies: R v4.1.2, tidyverse v2.0.0

library(tidyverse)
source("functions.R")
  
# define paths 
dio_orthobench = "../../results/scarap_pan/orthobench"
dio_parabench = "../../results/scarap_pan/parabench"
dio_lactos = "../../results/scarap_pan/lactobacillales_genusreps"

# compile and write resource consumption tables
print("compiling resource consumption tables")
for (dio in c(dio_orthobench, dio_parabench, dio_lactos)) {
  paste0(dio, "/tools") %>%
    toolsubdirs() %>%
    read_stats() %>%
    write_csv(paste0(dio, "/resources.csv"))
}

# compile and write pangenome tables
print("compiling pangenome tables")
for (dio in c(dio_orthobench, dio_parabench, dio_lactos)) {
  paste0(dio, "/tools") %>%
    toolsubdirs() %>%
    compile_pangenomes(has_genomes = "scarap_fh") %>%
    write_csv(paste0(dio, "/pangenomes.csv"))
}

# convert OrthoBench & ParaBench pangenomes to OrthoBench format
print("converting orthobench pangenomes to orthobench format")
pangenomes_to_orthobench(
  paste0(dio_orthobench, "/pangenomes.csv"), 
  paste0(dio_orthobench, "/orthobench_formatted")
)
print("converting parabench pangenomes to orthobench format")
pangenomes_to_orthobench(
  paste0(dio_parabench, "/pangenomes.csv"), 
  paste0(dio_parabench, "/orthobench_formatted")
)
