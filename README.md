# Benchmark SCARAP

The goal of this project is to demonstrate the pan, core and sample modules of the SCARAP toolkit for prokaryotic comparative genomics. 

The pangenome pipeline of SCARAP (pan module) is benchmarked against various publicly available pangenome tools. Three main benchmark datasets are used: (1) one representative genome for each genus of Lactobacillales, (2) OrthoBench and (3) paraBench. The core and sample modules are demonstrated on a dataset with Lactiplantibacillus genomes. 

## Data

`lactobacillales` 

* `accessions_genusreps.tsv` and `accessions_speciesreps.tsv`:
    * subsets of the table `bac120_metadata_r89.tsv`, downloaded from the GTDB
    * NCBI assembly accession number and genus name for one representative genome per genus/species of Lactobacillales
    * created by the script `src/01_prepare_lactobacillales/01_select_representatives.R`
* `genomes_ncbi`
    * fna file for one representative genome per species of Lactobacillales
    * downloaded by the script `scr/01_prepare_lactobacillales/02_download_genomes.sh`

`lactiplantibacillus` 

* `accessions.txt`:
    * subset of the table `bac120_metadata_r89.tsv`, downloaded from the GTDB
    * NCBI assembly accession number for all genomes of the species Lactiplantibacillus plantarum
    * created by the script `src/02_prepare_lplantarum/01_select_accessions.R`
* `genomes_ncbi`
    * fna file for each genome of the species L. plantarum
    * downloaded by the script `scr/02_prepare_lplantarum/02_download_genomes.sh`

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

`qfo2018/QfO_release_2018_04` (currently not used for the benchmarks)

* Quest for Orthologs reference datasets (2018)
* `ftp://ftp.ebi.ac.uk/pub/databases/reference_proteomes/previous_releases/qfo_release-2018_04/QfO_release_2018_04.tar.gz`

## Dependencies

### General dependencies 

R-related dependencies: 

* R v4.1.2
* tidyverse v2.0.0

### Pangenome tools used

[SCARAP v0.4.0](https://github.com/SWittouck/SCARAP)

* Install the dependencies listed on the GitHub README file. 
* Clone SCARAP from GitHub. 
* Make `scarap` point to `.../SCARAP/bin/scarap/scarap.py`. 

[OrthoFinder v2.5.4](https://github.com/davidemms/OrthoFinder)

* Install BLAST: `sudo apt install ncbi-blast+`. 
* Download the release with prepackaged executables.
* Make `orthofinder` point to `.../OrthoFinder/orthofinder`. 
* Remark: this OrthoFinder version didn't work with MMseqs2 version 6b93884, so to run OrthoFinder with MMseqs2 I ran OrthoFinder version bc18fe5 (directly cloned from GitHub). 

[SonicParanoid v1.3.8](http://iwasakilab.bs.s.u-tokyo.ac.jp/sonicparanoid/)

* Downloaded the tarball with source code from GitLab.
* In the file `setup.py, change `python_requires=">=3.6, <3.10"` to `python_requires=">=3.6, <3.11"``.
* From within the sonicparanoid folder, Run `pip3 install ./`. 

[Broccoli v1.2](https://github.com/rderelle/Broccoli)

* Install fasttree: `sudo apt install fasttree`.
* Install diamond. 
* Download the tarball with the source code from GitHub. 
* Create a script in your bin folder with the following code: `python3 .../broccoli.py #@` (replace ... with the full path). 

### Some other pangenome tools (currently unused)

[PEPPAN v1.0](https://github.com/zheminzhou/PEPPA)

* `pip3 install bio-peppa`
* executable is called `PEPPA`

[SwiftOrtho commit 2be2729](https://github.com/Rinoahu/SwiftOrtho)

* cloned the most recent version from GitHub and ran `bash install.sh`
* made sure that the `python` command referred to python3
* installed python modules with pip3: networkx and cffi

[MMseqs2 commit 45111b6 (version 13)](https://github.com/soedinglab/MMseqs2)

* downloaded the pre-compiled archive from GitHub

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
