#!/usr/local/epd/bin/python
#
#  find_image.py
#  dimage_py
#
#  Created by Adrian Price-Whelan on 6/3/09.
#  Copyright (c) 2009. All rights reserved.
#

import image_chop as ic
import sys
import os
import tarfile
os.environ['HOME'] = '/var/www/html/sdss3/skychop/sdss-tmp'

RADeg = float(sys.argv[1])
decDeg = float(sys.argv[2])
size = float(sys.argv[3])
bands = sys.argv[4]
tarName = sys.argv[5]

try:
	fileName, fileDir = ic.findClosestCenter(RADeg, decDeg)
	outDir = '/var/www/html/sdss3/skychop/sdss-tmp/'

	if fileDir[len(fileDir) - 1] != "/":
		fileDir = fileDir + "/"

	arcFileList = []
	for letter in bands:
		ic.gunzipIt(fileName + "-" + letter + ".fits.gz", fileDir+fileName+"/", outDir)
		ic.clipFits(outDir + fileName + "-" + letter + ".fits", RADeg, decDeg, size, outDir + fileName + "-" + letter + "-" + str(size) + ".fits")
		os.unlink(outDir + fileName + "-" + letter + ".fits")
		arcFileList.append("sdss-tmp/" + fileName + "-" + letter + "-" + str(size) + ".fits")

	tar = tarfile.open(outDir + tarName+".tar", "w")
	for name in arcFileList:
		tar.add(name)
		os.unlink(name)
	tar.close()

	ic.gzipIt(tarName+".tar", outDir)
	os.chmod(outDir+tarName+".tar.gz",0777)

	if os.path.isfile(outDir+tarName+".tar.gz"):
		print 1
	else: 
		print 0

except OSError:
	print "0"