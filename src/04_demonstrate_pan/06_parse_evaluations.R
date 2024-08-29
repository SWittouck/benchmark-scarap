#!/usr/bin/Rscript

# This script parses the orthobench and parabench output files into nice tables.

# depencencies: R v4.1.2, tidyverse v2.0.0

library(tidyverse)

source("functions.R")

din_orthobench <- "../../results/scarap_pan/orthobench/benchmarks"
din_parabench <- "../../results/scarap_pan/parabench/benchmarks"
fout_orthobench <- "../../results/scarap_pan/orthobench/benchmarks.csv"
fout_parabench <- "../../results/scarap_pan/parabench/benchmarks.csv"

tools_orthobench <- read_orthobench_files(din_orthobench)
tools_parabench <- read_parabench_files(din_parabench)

tools_orthobench %>% write_csv(fout_orthobench)
tools_parabench %>% write_csv(fout_parabench)