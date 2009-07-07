#!/usr/local/epd/bin/python
#
#  find_image.py
#  dimage_py
#
#  Created by Adrian Price-Whelan on 6/3/09.
#  Copyright (c) 2009. All rights reserved.
#

import os
# Enable this line for testing
os.environ['HOME'] = '/var/www/html/sdss3/skychop'
#os.environ['HOME'] = '/var/www/html/sdss3/skychop/sdss-tmp'
import image_chop as ic
import sys
import tarfile

### Collect user input in the form of shell arguments
RADeg = float(sys.argv[1])
decDeg = float(sys.argv[2])
sizeX, sizeY = float(sys.argv[3]),float(sys.argv[4])
bands = sys.argv[5]
tarName = sys.argv[6]
size = sizeX,sizeY
fitsPath = "/mount/hercules1/sdss/dr7sky/fits/"
dataFile = "sky-patches.fits"

fileName, fileDir = ic.findClosestCenter(RADeg, decDeg, fitsPath, dataFile)
outDir = '/var/www/html/sdss3/skychop/sdss-tmp/'

if fileDir[len(fileDir) - 1] != "/":
	fileDir = fileDir + "/"

arcFileList = []
for letter in bands:
	ic.gunzipIt(fileName + "-" + letter + ".fits.gz", fileDir+fileName, outDir)
	ic.clipFits(outDir + fileName + "-" + letter + ".fits", RADeg, decDeg, size, outDir + fileName + "-" + letter + "-" + str(sizeX) +"x"+ str(sizeY) + ".fits")
	os.unlink(outDir + fileName + "-" + letter + ".fits")
	arcFileList.append("sdss-tmp/" + fileName + "-" + letter + "-" + str(sizeX) +"x"+ str(sizeY) + ".fits")

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