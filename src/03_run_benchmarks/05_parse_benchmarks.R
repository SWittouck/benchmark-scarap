#!/usr/bin/Rscript

# This script will parse the orthobench and parabench output files into nice
# tables.

library(tidyverse)

source("functions.R")

din_orthobench <- "../../results/benchmarks/orthobench/benchmarks"
din_parabench <- "../../results/benchmarks/parabench/benchmarks"
fout_orthobench <- "../../results/benchmarks/orthobench/benchmarks.csv"
fout_parabench <- "../../results/benchmarks/parabench/benchmarks.csv"

tools_orthobench <- read_orthobench_files(din_orthobench)
tools_parabench <- read_parabench_files(din_parabench)

tools_orthobench %>% write_csv(fout_orthobench)
tools_parabench %>% write_csv(fout_parabench)