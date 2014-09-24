#!/usr/bin/python

import re
import sys
import os
import shutil

# arg 1: folder
folder = sys.argv[1]

# arg 2: extension for backup
backup_extension = sys.argv[2]

# list of files to be processed.
files = os.listdir(folder)

# iterate throught all the files in the directory
for file in files:
	# we ignore directories for now
	if os.path.isdir(file) or (not file.endswith(".k")):
		continue
	# open the file
	f = open(file)
	# read contents as string
	input_text = f.read()

	# we generate the regexp step by step
	re_name  = '([\s]*rule \[([^]]*)\]:[\s]*)'
	re_cells = '([\s]*[\s]*(<[^>]+>[^<]+<[^>]+>[\s]*)+[\s]*)'
	re_cond  = '([\s]*when [^\[]*[\s]*)'
	re_tags  = '([\s]*\[[^\]]*\][\s]*)'

	# and here is the final regexp
	pattern_with_cond = re_name + re_cells + re_cond + re_tags 
	pattern_without_cond = re_name + re_cells + re_tags 

	# let's compile this regexp
	p1 = re.compile(r'' + pattern_with_cond, re.M|re.S)
	p2 = re.compile(r'' + pattern_without_cond, re.M|re.S)

	# and now let's perform the substitution
	result = p1.sub(r'\1\3<trace> Trace:List => Trace ListItem("\2") </trace>\n\t\5\6', input_text)
	result = p2.sub(r'\1\3<trace> Trace:List => Trace ListItem("\2") </trace>\n\t\5', result)
	
	# make a backup copy of the present file
	backup_filename = file + '.' + backup_extension
	shutil.copy(file, backup_filename)
	
	# update the original file
	f = open(file, 'w')
	f.write(result)
	f.close()	