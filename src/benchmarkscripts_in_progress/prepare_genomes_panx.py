#!/usr/bin/env python3

# This script reformats the gene names in fasta files to "genome|gene".

# dependencies: python3, biopython

import gzip
import os
import re

from Bio import SeqIO, SeqRecord

def reformat_gene_names(din_fastas, dout_fastas):

    for file in os.listdir(din_fastas):
        fin_isolate = din_fastas + "/" + file
        fout_isolate = dout_fastas + "/" + file
        genome = re.findall(r"([^/]+)\.(fna|ffn|faa)\.gz", fin_isolate)[0][0]
        print(genome)
        with gzip.open(fin_isolate, "rt") as hin_isolate:
            with gzip.open(fout_isolate, "at") as hout_isolate:
                for record in SeqIO.parse(hin_isolate, "fasta"):
                    record.id = genome + "|" + record.id
                    SeqIO.write(record, hout_isolate, "fasta")

din_ffns = "../../results/lactobacillales/genes/ffns"
din_faas= "../../results/lactobacillales/genes/faas"
dout = "../../results/lactobacillales/benchmarks/panx"
                    
os.makedirs(, exist_ok = True)
                    
reformat_gene_names(din_ffns, dout)
reformat_gene_names(din_faas, dout)
