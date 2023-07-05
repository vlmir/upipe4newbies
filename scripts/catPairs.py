import sys
import glob
import pprint
import os
import subprocess
exp = sys.argv[1]
dirpth0 = sys.argv[2] # destination
dirpth1 = sys.argv[3] # src 1
dirpth2 = sys.argv[4] # src 2
## TODO adapt for multiple sources

'''
#! /usr/bin/env python3
cmd = 'ls  ' + dirpth1 + '*' + exp # file paths
files = subprocess.call(cmd, shell=True) # a list of files plus the exit code
files = os.system(cmd) # a list of files plus the exit code
files = subprocess.check_output(['ls', './']) # a list of files plus the exit code
'''
cmd = 'ls  ' + dirpth1 # bare file names
f = os.popen(cmd)
out = f.read()
files = out.split('\n')
for fl in files:
    if not fl: # the last value is ''
        continue
    src1 = dirpth1 + fl
    src2 = dirpth2 + fl
    trg = dirpth0 + fl
    cmd = 'cat ' + src1 + ' ' + src2 + ' > ' + trg
    os.system(cmd)

