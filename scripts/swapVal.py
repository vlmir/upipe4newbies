#! /usr/bin/python
### replaces values in a table
### USAGE:
## swapVal infile value replacement field
## infile - path
## value - string value to be replaced
## replacement - string
## field - int, index of the target field, indexing starts at '1'
## if field == 0 ALL fields are subjected to replacement

import sys
import csv
import pprint
FS = '\t'
CMT = '#'
path = sys.argv[1]
val1 = sys.argv[2]
val2 = sys.argv[3]
fidx = int(sys.argv[4]) - 1

def with_index(seq):
    for i in xrange(len(seq)):
        yield i, seq[i]

def replace_all(seq, obj, replacement):
    for i, elem in with_index(seq):
        if elem == obj:
            seq[i] = replacement

with open(path) as f:
    reader = csv.reader(f, delimiter=FS)
    for row in reader:
        if row[0][0] == CMT:
            continue
        if fidx > -1:
            if row[fidx] == val1:
                row[fidx] = val2
        else:
            replace_all(row, val1, val2)
        print FS.join(row)

