#!/usr/bin/env python3

# This script converts SCARAP pangenomes to OrthoXML format
# (see http://etetoolkit.org/docs/latest/tutorial/tutorial_etree2orthoxml.html)

import pandas as pd

fin_pan = "../../results/qfo2018_bacteria/benchmarks/SCARAP-FH/pangenome.tsv"

pan = pd.read_csv(fin, sep = "\t", names = ["gene", "genome", "orthogroup"])

