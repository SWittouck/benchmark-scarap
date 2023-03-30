##############
# Utilities  #
##############

#' Return a named list with subdirectories except "orthobench_format"
#' 
#' @param dir Path to a directory. 
#' @return A named list with subdirectory paths. 
toolsubdirs <- function(dir) {
  dir %>% 
    list.dirs(full.names = T, recursive = F) %>%
    setdiff(c("orthobench_format")) %>%
    `names<-`(., str_extract(., "[^/]+$"))
}

##################################
# Time/memory statistics parsing #
##################################

#' Read time/memory statistics file
#' 
#' Read a file with time/memory statistics as computed by `/usr/bin/time -v`. 
#' 
#' @param fin A path to a time/memory statistics file. 
#' @return A tibble with a single row. 
read_statfile <- function(fin) {
  if (! file.exists(fin)) return(NULL) # return NULL if non-existing statfile
  if (file.info(fin)[1, 1] == 0) return(NULL) # return NULL if empty statfile
  fin %>%
    read_lines() %>%
    keep(~ ! str_detect(., "^Command exited with non-zero status")) %>%
    str_trim() %>%
    str_remove_all(" \\([^()]*\\)") %>%
    tibble(text = .) %>%
    separate(col = text, into = c("stat", "value"), sep = ": ") %>%
    mutate(stat = str_to_lower(stat)) %>%
    mutate(stat = str_replace_all(stat, " ", "_")) %>%
    pivot_wider(names_from = stat, values_from = value)
}

#' Read multiple time/memory statistics files
#'
#' This function reads time/memory statistics files as computed by
#' `/usr/bin/time -v`. Given a named list of directories, all of which contain a
#' "stats.txt" file, a tibble with one row per directory will be returned.
#'
#' @param dins A named list of paths to directories with "stats.txt" files. 
#' @return A tibble with one row per directory. 
read_stats <- function(dins) {
  dins %>%
    map(paste0, "/stats.txt") %>%
    map(read_statfile) %>%
    keep(~ ! is.null(.)) %>%
    map2(names(.), ~ mutate(.x, tool = .y) %>% relocate(tool)) %>%
    reduce(bind_rows)
}

#####################
# Pangenome parsing #
#####################

#' Convert pangenomes to individual orthobench-format files
#'
#' Given a "pangenomes.csv" file, this function reads the pangenomes from this
#' file and writes a single orthobench-formatted pangenome file per pangenome
#' tool to the given output folder.
#'
#' @param fin A path to a file with pangenomes
#' @param dout A path to a folder to store the output files
pangenomes_to_orthobench <- function(fin, dout) {
  if (! dir.exists(dout)) dir.create(dout)
  pangenomes <- fin %>% read_csv(col_types = cols())
  for (tool in names(pangenomes) %>% setdiff(c("gene", "genome"))) {
    pangenomes %>%
      select(gene, genome, {{tool}}) %>%
      rename(orthogroup = {{tool}}) %>%
      group_by(orthogroup) %>%
      summarize(genes = str_c(gene, collapse = ", ")) %>%
      select(genes) %>%
      write_tsv(paste0(dout, "/", tool, ".txt"), col_names = F)
  }
}

#' Read a pangenome file
#'
#' Given the output directory of a pangenome tool, this function searches for
#' the pangenome file and reads it into a table with the columns "gene",
#' "genome" (if available) and "orthogroup". The function supports pangenomes
#' computed with OrthoFinder, SonicParanoid, Broccoli and SCARAP.
#' 
#' Remark: for Broccoli pangenomes, ORFans are not included in the output. 
#'
#' @param din The output directory of a pangenome tool.
#' @return A pangenome table (tibble).
read_pangenome <- function(din) {
  
  files <- list.files(din, include.dirs = T) 
  
  if ("OrthoFinder" %in% files) {
    read_pangenome_orthofinder(din) 
  } else if ("runs" %in% files) {
    read_pangenome_sonicparanoid(din) 
  } else if ("pangenome.tsv" %in% files) {
    read_pangenome_scarap(din) 
  } else if ("orthologous_groups.txt" %in% files) {
    read_pangenome_broccoli(din)
  } else {
    files
  }
  
}

# helper for read_pangenome
read_pangenome_orthofinder <- function(path) {
  
  path <- paste0(path, "/OrthoFinder/Results_*/Orthogroups")
  
  path_orthogroups <- 
    paste0(path, "/Orthogroups.?sv") %>% 
    Sys.glob()
  path_unassigned <- 
    paste0(path, "/Orthogroups_UnassignedGenes.?sv") %>% 
    Sys.glob()
  
  if (length(path_orthogroups) == 0) return(NULL)
  
  genes_assigned <- 
    path_orthogroups %>%
    readr::read_tsv(col_names = T, col_types = cols(.default = "c")) %>%
    rename(orthogroup = 1) %>%
    gather(key = "genome", value = "gene", na.rm = T, - orthogroup) %>%
    separate_rows(gene, sep = ", ")
  
  genes_unassigned <- 
    path_unassigned %>%
    readr::read_tsv(col_names = T, col_types = cols(.default = "c")) %>%
    rename(orthogroup = 1) %>%
    gather(key = "genome", value = "gene", na.rm = T, - orthogroup)
  
  genes <- bind_rows(genes_assigned, genes_unassigned)
  
  genes
  
}

# helper for read_pangenome
read_pangenome_sonicparanoid <- function(path) {
  
  path_groups <- 
    path %>%
    paste0("/runs/*/ortholog_groups/flat.ortholog_groups.tsv") %>%
    Sys.glob()
  
  path_singletons <-
    path %>%
    paste0("/runs/*/ortholog_groups/not_assigned_genes.ortholog_groups.tsv") %>%
    Sys.glob()
  
  if (length(path_groups) == 0) return(NULL)
  
  genes_groups <-
    path_groups %>%
    read_tsv(col_types = cols()) %>%
    rename(orthogroup = group_id) %>%
    pivot_longer(
      cols = - orthogroup, names_to = "genome", values_to = "gene"
    ) %>%
    filter(! gene == "*") %>%
    separate_rows(gene, sep = ",") %>%
    select(- genome) %>%
    mutate(orthogroup = str_c("G", orthogroup, sep = ""))
  
  genes_singleton <-
    path_singletons %>%
    read_lines() %>%
    tibble(gene = .) %>%
    filter(! str_starts(gene, "#"), ! gene == "") %>%
    mutate(orthogroup = str_c("S", 1:n()))
  
  bind_rows(genes_groups, genes_singleton)
  
}

# helper for read_pangenome
read_pangenome_broccoli <- function(path) {
  
  colnames <- c("orthogroup", "gene")
  fin <- path %>% paste0("/orthologous_groups.txt")
  if (! file.exists(fin)) return(NULL)
  fin %>%
    read_tsv(skip = 1, col_types = cols(), col_names = colnames) %>%
    separate_rows(gene, sep = " ")
  
}

# helper for read_pangenome
read_pangenome_scarap <- function(path) {
  
  fin <- path %>% paste0("/pangenome.tsv")
  if (! file.exists(fin)) return(NULL)
  fin %>%
    read_tsv(
      col_names = c("gene", "genome", "orthogroup"), col_types = cols()
    )
  
}

#' Read multiple pangenome files
#'
#' Given a named list of directories, all of which contain the output of a
#' pangenome tool, this function reads all pangenomes and returns them as a
#' single gene table with the columns "gene" and "genome", and a single
#' orthogroup column per pangenome tool.
#'
#' @param dins A named list of paths to pangenome output directories. 
#' @return A gene table (tibble). 
compile_pangenomes <- function(dins, has_genomes) {
  
  pans <- dins %>% map(read_pangenome) %>% keep(~ ! is.null(.))
  
  pans %>%
    map(~ select(., ! matches("genome"))) %>%
    map2(names(.), ~ rename(.x, !! .y := orthogroup)) %>%
    reduce(full_join, by = "gene") %>%
    left_join(pans[[has_genomes]] %>% select(gene, genome), by = "gene") %>%
    relocate(gene, genome)
  
}

##############################
# Benchmark results parsing  #
##############################

#' Read OrthoBench benchmarking output file
#' 
#' Read file produced by the script OrthoBench_v1.1/benchmark.py
#' 
#' @param fin A path to an OrthoBench output file.
#' @return A tibble with a single row. 
read_orthobench_file <- function(fin) {
  if (! file.exists(fin)) return(NULL) # return NULL if non-existing file
  if (file.info(fin)[1, 1] == 0) return(NULL) # return NULL if empty file
  tool <- str_extract(fin, "[^/]+(?=\\.txt)")
  stats <- 
    fin %>%
    read_lines() %>%
    keep(~ str_detect(., "F-score|Precision|Recall|exactly correct")) %>%
    str_trim() %>%
    tibble(text = .) %>%
    separate(
      col = text, into = c("value", "stat"), sep = " ", extra = "merge"
    ) %>%
    mutate(stat = str_to_lower(stat)) %>%
    mutate(stat = str_replace_all(stat, "[ -]", "_")) %>%
    mutate(tool = {{tool}}) %>%
    pivot_wider(names_from = stat, values_from = value) %>%
    relocate(tool)
  if (nrow(stats) == 0) return(NULL) else return(stats)
}

#' Read multiple OrthoBench benchmarking files
#'
#' This function reads all OrthoBench benmarking output files in a given
#' directory and parses them into a nice table.
#'
#' @param din A directory with OrthoBench benchmarking files.
#' @return A tibble with one row per OrthoBench file.
read_orthobench_files <- function(din) {
  din %>%
    list.files(full.names = T) %>%
    map(read_orthobench_file) %>%
    keep(~ ! is.null(.)) %>%
    reduce(bind_rows)
}

#' Read paraBench benchmarking output file
#' 
#' Read file produced by the script paraBench/paraBench.py.
#' 
#' @param fin A path to an paraBench output file.
#' @return A tibble with a single row. 
read_parabench_file <- function(fin) {
  if (! file.exists(fin)) return(NULL) # return NULL if non-existing file
  if (file.info(fin)[1, 1] == 0) return(NULL) # return NULL if empty file
  tool <- str_extract(fin, "[^/]+(?=\\.txt)")
  stats <- 
    fin %>%
    read_lines() %>%
    keep(~ str_detect(., "TP|FP|FN|precision|recall|F1-score")) %>%
    str_trim() %>%
    tibble(text = .) %>%
    separate(col = text, into = c("stat", "value"), sep = " = ") %>%
    mutate(stat = str_to_lower(stat)) %>%
    mutate(stat = str_trim(stat)) %>%
    mutate(stat = str_replace_all(stat, "[ -]", "_")) %>%
    mutate(tool = {{tool}}) %>%
    pivot_wider(names_from = stat, values_from = value) %>%
    relocate(tool)
  if (nrow(stats) == 0) return(NULL) else return(stats)
}

#' Read multiple paraBench benchmarking files
#'
#' This function reads all paraBench benmarking output files in a given
#' directory and parses them into a nice table.
#'
#' @param din A directory with paraBench benchmarking files.
#' @return A tibble with one row per paraBench file.
read_parabench_files <- function(din) {
  din %>%
    list.files(full.names = T) %>%
    map(read_parabench_file) %>%
    keep(~ ! is.null(.)) %>%
    reduce(bind_rows)
}

###########
# Unused  #
###########

compile_times <- function(dins) {
  
  dins %>%
    map(~ .x %>% paste0("/time.txt") %>% read_lines()) %>%
    as_tibble() %>%
    pivot_longer(
      cols = everything(), names_to = "tool", values_to = "time"
    ) %>%
    mutate(time = as.integer(time))
  
}