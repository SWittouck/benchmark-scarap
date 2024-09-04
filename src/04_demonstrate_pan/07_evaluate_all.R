#!/usr/bin/Rscript

# This script parses the orthobench and parabench output files into nice tables.

# depencencies: R v4.1.2, tidyverse v2.0.0

library(tidyverse)
source("functions.R")

dio_datasets <- "../../results/scarap_pan"

din_benchmarks_orthobench <- "../../results/scarap_pan/orthobench/benchmarks"
din_benchmarks_parabench <- "../../results/scarap_pan/parabench/benchmarks"
fin_benchmarks_tonkinhill <- "../../results/scarap_pan/tonkinhill/benchmarks.csv"

fout_orthobench <- "../../results/scarap_pan/orthobench/benchmarks.csv"
fout_parabench <- "../../results/scarap_pan/parabench/benchmarks.csv"
fout_repseqs <- "../../results/scarap_pan/repseqs/benchmarks.csv"

#############
# read data #
#############

# read all pangenomes
pans_list <- 
  list.files(dio_datasets, full.names = T) %>%
  set_names(basename(.)) %>%
    {.[! names(.) %in% "lactobacillales_speciesreps"]} %>%
  map(function(path) {
    paste0(path, "/pangenomes.csv.gz") %>%
      read_csv(col_types = cols(.default = "c"))
  })

# read orthobench, parabench and tonkinhill evaluations
tools_orthobench <- read_orthobench_files(din_benchmarks_orthobench)
tools_parabench <- read_parabench_files(din_benchmarks_parabench)
tools_tonkinhill <- 
  read_csv(fin_benchmarks_tonkinhill, col_types = cols(.default = "c"))

##################################
# calculate and write statistics # 
##################################

# compute pangenome statistics for all datasets
statistics_list <- pans_list %>% map(pangenome_stats_all)

# write statistics
for (dataset in names(statistics_list)) {
  statistics_list[[dataset]] %>% 
    write_csv(paste0(dio_datasets, "/", dataset, "/statistics.csv"))
}

################################
# process and write benchmarks # 
################################

# process orthobench and parabench evaluations
tools_orthobench <-
  tools_orthobench %>%
  mutate(across(
    c(f_score, precision, recall), 
    ~ str_remove(., "%$") %>% as.double() %>% `/`(100)
  )) %>%
  select(tool, f_measure = f_score, precision, recall)
tools_parabench <-
  tools_parabench %>%
  select(tool, precision, recall, f_measure = f1_score)

# for repseqs funs: compute precrec values with respect to most accurate run
runs_repseqs <- 
  pans_list$repseqs %>% 
  precrec_table(ref_pangenome = minreps128_maxreps0p_maxalign1f)

# write benchmarks
tools_orthobench %>% write_csv(fout_orthobench)
tools_parabench %>% write_csv(fout_parabench)
runs_repseqs %>% write_csv(fout_repseqs)
