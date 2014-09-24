#!/usr/bin/python

import sys
import os
import re

folder = sys.argv[1]
output_file  = "rules-list.txt"

# initialize list
list_of_rules = ""
files = os.listdir(folder)
# iterate throught all the files in the directory
for file in files:
	# we ignore directories for now
	if os.path.isdir(file) or (not file.endswith(".k")):
		continue
	# open the file
	f = open(file)
	input_data = f.read().split("\n")
	for line in input_data:
		match = re.match('([\s]*rule \[([^]]*)\]:[\s]*)', line) 
		if match:
			list_of_rules += match.group(2) + "\n"
	
out = open(output_file, 'w')
out.write(list_of_rules)
out.close()