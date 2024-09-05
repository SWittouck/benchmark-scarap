#!/usr/bin/Rscript

# This script produces two tables for some/all datasets:
# - A table with pangenome statistics (number of single-copy core genes etc)
#   for all datasets. 
# - A table with benchmarks (precision, recall, f-measure) for the simpan,
# - tonkinhill, OrthoBench, paraBench and repseqs datasets. 

# depencencies: R, tidyverse

library(tidyverse)
source("functions.R")

# location of folder with subfolder per dataset that contains pangenomes etc
dio_datasets <- "../../results/scarap_pan"

# locations of reference pangenomes
fin_refpan_simpan <- "../../results/simpan/reference_pangenome.tsv"
fin_refpan_tonkinhill <- "../../results/tonkinhill/reference_pangenome.tsv"

# locations of precomputed orthobench and parabench benchmarks
din_benchmarks_orthobench <- "../../results/scarap_pan/orthobench/benchmarks"
din_benchmarks_parabench <- "../../results/scarap_pan/parabench/benchmarks"

# locations for bechmark output tables
fout_benchmarks_simpan <- "../../results/scarap_pan/simpan/benchmarks.csv"
fout_benchmarks_tonkinhill <- "../../results/scarap_pan/toninhill/benchmarks.csv"
fout_benchmarks_orthobench <- "../../results/scarap_pan/orthobench/benchmarks.csv"
fout_benchmarks_parabench <- "../../results/scarap_pan/parabench/benchmarks.csv"
fout_benchmarks_repseqs <- "../../results/scarap_pan/repseqs/benchmarks.csv"

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

# read simpan and tonkinhill reference pangenomes
colnames <- c("gene", "genome", "orthogroup")
refpan_simpan <- 
  fin_refpan_simpan %>%
  read_tsv(col_names = colnames, col_types = cols(.default = "c"))
refpan_tonkinhill <- 
  fin_refpan_tonkinhill %>%
  read_tsv(col_names = colnames, col_types = cols(.default = "c"))

# read orthobench, parabench and tonkinhill benchmarks
runs_orthobench <- read_orthobench_files(din_benchmarks_orthobench)
runs_parabench <- read_parabench_files(din_benchmarks_parabench)

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

##############################
# compute/compile benchmarks #
##############################

# compute simpan, tonkinhill and repseqs benchmarks
runs_simpan <- 
  pans_list$simpan %>% 
  left_join(refpan_simpan, by = c("gene", "genome")) %>%
  precrec_table(ref_pangenome = orthogroup)
runs_tonkinhill <- 
  pans_list$tonkinhill %>% 
  left_join(refpan_tonkinhill, by = c("gene", "genome")) %>%
  precrec_table(ref_pangenome = orthogroup)
runs_repseqs <- 
  pans_list$repseqs %>% 
  precrec_table(ref_pangenome = minreps128_maxreps0p_maxalign1f)

# compile orthobench and parabench benchmarks
runs_orthobench <-
  runs_orthobench %>%
  mutate(across(
    c(f_score, precision, recall), 
    ~ str_remove(., "%$") %>% as.double() %>% `/`(100)
  )) %>%
  select(tool, f_measure = f_score, precision, recall)
runs_parabench <-
  runs_parabench %>%
  select(tool, precision, recall, f_measure = f1_score)

################################
# process and write benchmarks # 
################################

# write benchmarks
runs_simpan %>% write_csv(fout_benchmarks_simpan)
runs_tonkinhill %>% write_csv(fout_benchmarks_tonkinhill)
runs_orthobench %>% write_csv(fout_benchmarks_orthobench)
runs_parabench %>% write_csv(fout_benchmarks_parabench)
runs_repseqs %>% write_csv(fout_benchmarks_repseqs)
