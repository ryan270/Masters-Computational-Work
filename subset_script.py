#!/usr/bin/env python
# -*- coding: utf-8 -*-

#python code that subsets a fasta file
#execution format:
#  python ./subset_script.py [input_file.fasta] [sample_ids.TXT] [output.fasta]
# files need to be in the same directory
import sys
from Bio import SeqIO

fasta_file = sys.argv[1] #input fasta file
number_file = sys.argv[2] #input numbers: one per line
result_file = sys.argv[3] #output fasta file

wanted = set()
with open(number_file) as f:
    for line in f:
       line = line.strip()
       if line !="":
          wanted.add(line)
fasta_sequences = SeqIO.parse(open(fasta_file), 'fasta-2line') #changed file format to 'fasta-2line'
end = False
with open(result_file, "w") as f:
    for seq in fasta_sequences:
       if seq.id in wanted:
          SeqIO.write([seq], f, "fasta-2line")
