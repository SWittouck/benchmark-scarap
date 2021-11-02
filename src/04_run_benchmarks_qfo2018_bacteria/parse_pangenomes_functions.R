
#' Read a pangenome file
#'
#' Given the output directory of a pangenome tool, this function searches for
#' the pangenome file and reads it into a table with the columns "gene",
#' "genome" (if available) and "orthogroup". The function supports pangenomes
#' computed with OrthoFinder, SonicParanoid and SCARAP.
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

compile_times <- function(dins) {
  
  dins %>%
    map(~ .x %>% paste0("/time.txt") %>% read_lines()) %>%
    as_tibble() %>%
    pivot_longer(
      cols = everything(), names_to = "tool", values_to = "time"
    ) %>%
    mutate(time = as.integer(time))
  
}