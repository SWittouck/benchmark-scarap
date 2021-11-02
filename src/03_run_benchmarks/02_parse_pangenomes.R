#!/usr/bin/env Rscript

# This script parses the pangenomes inferred by various tools on various
# datasets into a nice gene table and into the OrthoBench format. In addition,
# the time/memory stats are converted to a table. 

# depencencies: tidyverse v1.3.0

library(tidyverse)
source("functions.R")
  
# define paths 
dio_orthobench = "../../results/benchmarks/orthobench"
dio_parabench = "../../results/benchmarks/parabench"
dio_lactos = "../../results/benchmarks/lactobacillales"

# compile and write resource consumption tables
for (dio in c(dio_orthobench, dio_parabench, dio_lactos)) {
  paste0(dio, "/tools") %>%
    toolsubdirs() %>%
    read_stats() %>%
    write_csv(paste0(dio, "/resources.csv"))
}

# compile and write pangenome tables
for (dio in c(dio_orthobench, dio_parabench, dio_lactos)) {
  paste0(dio, "/tools") %>%
    toolsubdirs() %>%
    compile_pangenomes(has_genomes = "scarap_fh") %>%
    write_csv(paste0(dio, "/pangenomes.csv"))
}

# convert OrthoBench & ParaBench pangenomes to OrthoBench format
pangenomes_to_orthobench(
  paste0(dio_orthobench, "/pangenomes.csv"), 
  paste0(dio_orthobench, "/orthobench_formatted")
)
pangenomes_to_orthobench(
  paste0(dio_parabench, "/pangenomes.csv"), 
  paste0(dio_parabench, "/orthobench_formatted")
)
