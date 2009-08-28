#
#  apw_utils.py
#  dimage
#
#  Created by Adrian Price-Whelan on 8/3/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

from math import sqrt
import gzip
from shutil import move
import operator

def remDupes(seq):
    seen = set()
    return [x for x in seq if x not in seen and not seen.add(x)]
	
def repDupesWithZero(seq): 
	def idfun(x): return x
	seen = {}
	result = []
	for item in seq:
		marker = idfun(item)
		if marker not in seen:
			seen[marker] = 1
			result.append(item)
		else:
			seen[marker] = 1
			result.append(0)
	return result

def gzipIt(file, outDir):
	r_file = open(outDir+file, 'r')
	w_file = gzip.GzipFile(outDir+file + '.gz', 'w', 9)
	w_file.write(r_file.read())
	w_file.flush()
	w_file.close()
	r_file.close()
	os.unlink(outDir+file)
	return None

def gunzipIt(file, fileDir, outDir):
	r_file = gzip.GzipFile(fileDir + "/" + file, 'r')
	write_file = outDir + file[:-3]
	w_file = open(write_file, 'w')
	w_file.write(r_file.read())
	w_file.close()
	r_file.close()
	move(write_file,outDir + file[:-3])
	return None

def midpt((x,y),(u,v)):
	return ((x+u)/2.0,(y+v)/2.0)
def dist((x,y),(u,v)):
	return sqrt((x-u)**2+(y-v)**2)