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
	# make full path names for both original and backup files
	filename = folder + "/" + file
	backup_filename = folder + "/" + file + '.' + backup_extension
	# make a backup copy of the present file
	shutil.copy(filename, backup_filename)
	# open the file
	f = open(filename)
	# initialise result
	result = ""
	# take all lines from original file not containing <trace>
	for line in f:
		if not "<trace>" in line:
			result = result + line
	# update the original file
	f = open(filename, 'w')
	f.write(result)
	# and finally close the file
	f.close()	