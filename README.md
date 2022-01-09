# Benchmark SCARAP

The goal of this project is to demonstrate the pan, core and clust modules of the SCARAP toolkit for prokaryotic comparative genomics. 

The pangenome pipeline of SCARAP (pan module) is benchmarked against various publicly available pangenome tools. Three benchmark datasets are used: (1) one representative genome for each genus of Lactobacillales, (2) OrthoBench and (3) paraBench. The core and clust modules are demonstrated on a dataset with Lactiplantibacillus plantarum genomes. 

## Data

`lactobacillales_genera/genomes.tsv` 

* subset of the table `bac120_metadata_r89.tsv`, downloaded from the GTDB
* NCBI assembly accession number and genus name for one representative genome per genus of Lactobacillales
* created by the script `src/01_dataprep_lactobacillales/01_select_accessions.R`

`lactobacillales_genera/genomes_ncbi`

* fna files for one representative genome per genus of Lactobacillales
* downloaded by the script `src/01_dataprep_lactobacillales/02_download_genomes.R`

`orthobench/OrthoBench_v1.1`

* downloaded from <https://github.com/davidemms/Open_Orthobench/releases>
* gzipped all proteomes (`gzip Input/*.fa`)
* instructions on how to benchmark: <https://github.com/davidemms/Open_Orthobench>

`parabench/paraBench`

* cloned from <https://github.com/rderelle/paraBench> (commit 05cae01)
* unzipped four zip files with proteomes and put them in data/proteomes
* removed four original zip files
* gzipped all proteomes (`gzip data/proteomes/*.fasta`)
* gave the script paraBench.py execution permission

`qfo2018/QfO_release_2018_04`

* Quest for Orthologs reference datasets (2018)
* `ftp://ftp.ebi.ac.uk/pub/databases/reference_proteomes/previous_releases/qfo_release-2018_04/QfO_release_2018_04.tar.gz`

## Dependencies

[SCARAP v0.3.1](https://github.com/SWittouck/SCARAP)

[OrthoFinder v2.3.11](https://github.com/davidemms/OrthoFinder)

* downloaded the release with prepackaged executables

[SonicParanoid v1.3.0](http://iwasakilab.bs.s.u-tokyo.ac.jp/sonicparanoid/)

* followed the instructions for Linux on the website

[PEPPAN v1.0](https://github.com/zheminzhou/PEPPA)

* `pip3 install bio-peppa`
* executable is called `PEPPA`

[SwiftOrtho commit 2be2729](https://github.com/Rinoahu/SwiftOrtho)

* cloned the most recent version from GitHub and ran `bash install.sh`
* made sure that the `python` command referred to python3
* installed python modules with pip3: networkx and cffi

[MMseqs2 commit d36dea2](https://github.com/soedinglab/MMseqs2)

* don't remember how I installed (I should maybe upgrade)

[PIRATE v1.0.4](https://github.com/SionBayliss/PIRATE)

* cloned the most recent version from GitHub
* created a symbolic link to `bin/PIRATE` in `~/bin/`

[panX commit 805c7ff](https://github.com/neherlab/pan-genome-analysis)

* installed miniconda (distribution of python that includes conda):
    * downloaded and ran the installer for linux: <https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh>
    * added the following line to the .bashrc file: `export PATH="/home/stijn/miniconda3/bin:$PATH"`
* installed panX with all dependencies
    * cloned the most recent version from GitHub
    * ran `conda env create -f panX-environment.yml`
    * created a symbolic link to panX.py (just named "panX") in `~/bin/`
* to use panX, first activiate its conda environment by running `source activate panX`

R-related dependencies: 

* R v3.6.3
* tidyverse v1.3.0
