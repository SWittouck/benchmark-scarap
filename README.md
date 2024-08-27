# Benchmark SCARAP

The goal of this project is to demonstrate the pan, core and sample modules of the SCARAP toolkit for prokaryotic comparative genomics. 

The pangenome pipeline of SCARAP (pan module) is benchmarked against various publicly available pangenome tools. Three main benchmark datasets are used: (1) one representative genome for each genus of *Lactobacillales*, (2) OrthoBench and (3) paraBench. The core and sample modules are demonstrated on a dataset with *Lactiplantibacillus* genomes. 

## How to run 

Step 1: clone this repository and create a data folder within it: `mkdir data`. 

Step 2: manually prepare the OrthoBench benchmark dataset. 

1. Create a folder `data/orthobench` and go to it: `mkdir data/orthobench ; cd data/orthobench`. 
1. Download the file `BENCHMARKS.tar.gz` from the [Open_Orthobench repository](https://github.com/davidemms/Open_Orthobench/releases), release v1.1. 
1. Unarchive the file: `tar xzf BENCHMARKS.tar.gz`. 
1. Rename the unarchived folder to `OrthoBench_v1.1`. 
1. Compress the proteomes: `gzip OrthoBench_v1.1/Input/.fa`. 

Step 3: manually prepare the paraBench benchmark dataset. 

1. Create a folder `data/parabench` and go to it: `mkdir data/parabench ; cd data/parabench`. 
1. Clone the paraBench repository from <https://github.com/rderelle/paraBench> (commit 05cae01).
1. Go to the data folder of paraBench and unzip the proteome files: `for zip in proteomes__*.zip ; do unzip $zip ; done`.
1. Create a folder "proteomes" and move the fasta files there: `mkdir proteomes ; mv *.fasta proteomes`. 
1. Compress all proteomes: `gzip proteomes/*.fasta`. 
1. Give the script paraBench.py execution permission: `sudo chmod u+x paraBench.py`. 

Step 4: install all dependencies except Broccoli in a virtual environment and activate it: 

    conda env create -f environment.yml --prefix ./env
    conda activate ./env
    
Step 5: manually install Broccoli: 

1. Download the tarball with the source code from GitHub and unpack. 
1. Create a script in `~/bin/` with the following code: `python3 <path-to-repo>/broccoli.py #@` 

Step 6: run the scripts in `src` in the order indicated by the file and folder name prefixes. 

## Dependencies

R-related dependencies: 

* R v4.1.2
* tidyverse v2.0.0

gene prediction: Prodigal 

pangenome tools: 

* [SCARAP v0.4.0](https://github.com/SWittouck/SCARAP)
* [OrthoFinder v2.5.2](https://github.com/davidemms/OrthoFinder)
* [SonicParanoid v1.3.8](https://gitlab.com/salvo981/sonicparanoid2)
* [Broccoli v1.2](https://github.com/rderelle/Broccoli)
* [PIRATE v1.0.5](https://github.com/SionBayliss/PIRATE)

## Datasets

Here follows a brief description of the files in the benchmark datasets.

`data/lactobacillales` (created by code in `scr/01_prepare_lactobacillales`)

* `accessions_genusreps.tsv` and `accessions_speciesreps.tsv`:
    * subsets of the table `bac120_metadata_r207.tsv`, downloaded from the GTDB
    * NCBI assembly accession number and genus name for one representative genome per genus/species of Lactobacillales
    * created by the script `src/01_prepare_lactobacillales/01_select_representatives.R`
* `genomes_ncbi`
    * fna file for one representative genome per species of Lactobacillales
    * downloaded by the script `scr/01_prepare_lactobacillales/02_download_genomes.sh`

`data/lactiplantibacillus` (created by code in `scr/02_prepare_lactiplantibacillus`)

* `accessions.txt`:
    * subset of the table `bac120_metadata_r207.tsv`, downloaded from the GTDB
    * NCBI assembly accession number for all genomes of the species Lactiplantibacillus plantarum
    * created by the script `src/02_prepare_lplantarum/01_select_accessions.R`
* `genomes_ncbi`
    * fna file for each genome of the species L. plantarum
    * downloaded by the script `scr/02_prepare_lplantarum/02_download_genomes.sh`

`data/orthobench/OrthoBench_v1.1`

* proteomes and benchmarking code for the OrthoBench dataset
* instructions on how to benchmark: <https://github.com/davidemms/Open_Orthobench>

`data/parabench/paraBench`

* proteomes and benchmarking code for the paraBench dataset