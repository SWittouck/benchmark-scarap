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

###############################
# Resource statistics parsing #
###############################

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
#' computed with OrthoFinder, SonicParanoid, Broccoli, PIRATE and SCARAP.
#' 
#' Remark: for Broccoli pangenomes, ORFans are not included in the output. For
#' PIRATE pangenomes, some genes are not present in the output because they 
#' are filtered out by PIRATE (e.g. short genes). 
#'
#' @param din The output directory of a pangenome tool.
#' @return A pangenome table (tibble).
read_pangenome <- function(din) {
  
  files <- list.files(din, include.dirs = T) 
  
  if ("OrthoFinder" %in% files) {
    message("OrthoFinder pangenome detected")
    read_pangenome_orthofinder(din) 
  } else if ("runs" %in% files) {
    message("SonicParanoid pangenome detected")
    read_pangenome_sonicparanoid(din) 
  } else if ("pangenome.tsv" %in% files) {
    message("SCARAP pangenome detected")
    read_pangenome_scarap(din) 
  } else if ("orthologous_groups.txt" %in% files) {
    message("Broccoli pangenome detected")
    read_pangenome_broccoli(din)
  } else if ("PIRATE.gene_families.tsv" %in% files) {
    message("PIRATE pangenome detected")
    read_pangenome_pirate(din)
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
read_pangenome_pirate <- function(path) {
  
  fin <- paste0(path, "/PIRATE.gene_families.tsv")
  if (! file.exists(fin)) return(NULL)
  pan <- 
    fin %>%
    read_tsv(col_types = cols()) %>%
    select(orthogroup = gene_family, 21:last_col()) %>%
    pivot_longer(
      - orthogroup, names_to = "genome", values_to = "gene_pirate", 
      values_drop_na = T
    ) %>%
    mutate(gene_pirate = str_remove_all(gene_pirate, "[()]")) %>%
    mutate(gene_pirate = str_replace_all(gene_pirate, ":", ";")) %>%
    separate_rows(gene_pirate, sep = ";")
  genes <- 
    paste0(path, "/modified_gffs") %>%
    list.files(full.names = T) %>%
    map(function(path) {
      message(paste0("PIRATE - extracting gene names from ", basename(path)))
      path %>%
        read_lines() %>%
        {.[1:which(str_detect(., "^##FASTA"))]} %>%
        {.[! str_detect(., "^#")]} %>%
        tibble(all = .) %>%
        separate(all, into = str_c("X", 1:9), sep = "\t") %>%
        select(contig = X1, feature = X3, attributes = X9) %>%
        filter(feature == "CDS") %>%
        mutate(gene_pirate = str_extract(attributes, "(?<=ID=)[^;]+")) %>%
        mutate(gene = str_extract(attributes, "(?<=prev_ID=)[^;]+")) %>%
        select(gene_pirate, gene)
    }) %>%
    reduce(.f = bind_rows)
  pan %>%
    left_join(genes, by = "gene_pirate") %>%
    select(gene, genome, orthogroup)
  
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
#' @param has_genomes Name of the pangenome to take the genome column from. 
#' @return A gene table (tibble). 
compile_pangenomes <- function(dins, has_genomes) {
    
  pans <- dins %>% map(read_pangenome) %>% keep(~ ! is.null(.))

  if (! has_genomes %in% names(pans)) has_genomes <- 1
  genes <- pans[[has_genomes]] %>% select(gene, genome)
  
  pans %>%
    map(~ select(., ! matches("genome"))) %>%
    map2(names(.), ~ rename(.x, !! .y := orthogroup)) %>%
    reduce(full_join, by = "gene") %>%
    left_join(genes, by = "gene") %>%
    relocate(gene, genome)
  
}

#########################
# Pangenome evaluation  #
#########################

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

#' Compute the f-measure
#' 
#' Given a vector with predicted groups and a vector with reference groups of 
#' objects, this function calculates the precision, recall and f-measure of the
#' predicted groups.  
#' 
#' @param group_pred A vector with predicted groups. 
#' @param group_ref A vector with reference groups. 
#' 
#' @return A list with the elements "precision", "recall" and "f_measure".
f_measure <- function(group_pred, group_ref) {
  
  pan <- 
    tibble(cluster_pred = group_pred, cluster_ref = group_ref) %>%
    filter(! is.na(cluster_ref))
  
  counts <- 
    pan %>% 
    filter(! is.na(cluster_pred)) %>%
    count(cluster_ref, cluster_pred)
  clusters_ref <-
    counts %>%
    group_by(cluster_ref) %>%
    summarize(majority_pred_cluster = cluster_pred[which.max(n)])
  clusters_pred <-
    counts %>%
    group_by(cluster_pred) %>%
    summarize(majority_ref_cluster = cluster_ref[which.max(n)])
  pan %>%
    left_join(clusters_ref, by = "cluster_ref") %>%
    left_join(clusters_pred, by = "cluster_pred") %>%
    summarize(
      precision = sum(majority_ref_cluster == cluster_ref, na.rm = T) / n(),
      recall = sum(majority_pred_cluster == cluster_pred, na.rm = T) / n()
    ) %>%
    {list(
      precision = .$precision, recall = .$recall,
      f_measure = 2 / ((1 / .$precision) + (1 / .$recall))
    )}
  
}

#' Calculate precision and recall for pangenomes
#' 
#' @param pans A tibble with the columns gene and genome, and one column
#'   per pangenome tool with the orthogroups inferred by that tool. 
#' @param ref_pangenome The column in "pans" that contains the reference 
#'   pangenome. 
#'   
#' @return A tibble with the column tool and a bunch of columns with pangenome
#'   statistics. 
precrec_table <- function(pans, ref_pangenome) {
  ref_pangenome <- enquo(ref_pangenome) 
  pans %>%
    select(- gene, - genome, - {{ref_pangenome}}) %>%
      map2(names(.), function(group_pred, tool) {
        f_measure(group_pred, pull(pans, {{ref_pangenome}})) %>% 
          as_tibble() %>%
          mutate(tool = {{tool}})
      }) %>%
      reduce(bind_rows) %>%
      relocate(tool)
}

#' Calculate pangenome statistics for a single pangenome
#' 
#' @param pan A tibble with the columns gene, genome and orthogroup. 
#' @param orthogroup A quoted alternative name for the orthogroup column. 
#' 
#' @return A named list with pangenome statistics
pangenome_stats_one <- 
  function(pan, orthogroup = "orthogroup", core_threshold = 0.95) {
  
  stats <- list()
  
  # preparation
  pan <- pan %>% select(gene, genome, orthogroup = all_of(orthogroup))
  orthogroups <- 
    pan %>%
    count(genome, orthogroup, name = "n_copies") %>%
    group_by(orthogroup) %>%
    summarize(
      n_genomes = n(),
      n_genomes_sc = sum(n_copies == 1),
      n_genes = sum(n_copies),
      av_copies = n_genes / n_genomes,
      .groups = "drop"
    )
    
  # number of orthogroups and genomes
  stats$genomes <- length(unique(pan$genome))
  stats$orthogroups <- nrow(orthogroups)
  
  # number of (single-copy) core orthogroups
  stats$core_orthogroups <- 
    sum(orthogroups$n_genomes >= core_threshold * stats$genomes)
  stats$sc_core_orthogroups <- 
    sum(orthogroups$n_genomes_sc >= core_threshold * stats$genomes)
    
  # average single-copy occurrence of orthogroups
  stats$av_sc_occurrence <-
    orthogroups %>%
    {sum(.$n_genes * .$n_genomes_sc) / sum(.$n_genes)}
  
  stats
  
  }

#' Calculate pangenome statistics for all pangenomes in a table
#' 
#' @param pans A tibble with the columns gene and genome, and one column
#'   per pangenome tool with the orthogroups inferred by that tool. 
#'   
#' @return A tibble with the column tool and a bunch of columns with pangenome
#'   statistics. 
pangenome_stats_all <- function(pans) {
  
  names(pans) %>%
    setdiff(c("gene", "genome")) %>%
    {structure(., names = .)} %>%
    map(~ pangenome_stats_one(pans, orthogroup = .x)) %>%
    map2(names(.), ~ {.x$tool <- .y; .x}) %>%
    transpose() %>%
    map(as_vector) %>%
    as_tibble() %>%
    relocate(tool)
  
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