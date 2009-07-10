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
#os.environ['HOME'] = '/var/www/html/sdss3/skychop'
#os.environ['HOME'] = '/var/www/html/sdss3/skychop/sdss-tmp'
import image_chop as ic
import sys
import tarfile
import pyfits as pf
from math import sqrt, fabs

### FOR TESTING ###
import matplotlib.pyplot as plt

### Collect user input in the form of shell arguments
RADeg = float(sys.argv[1])
decDeg = float(sys.argv[2])
xSize, ySize = float(sys.argv[3]),float(sys.argv[4])
bands = sys.argv[5]
tarName = sys.argv[6]
size = xSize, ySize
fitsPath = "/mount/hercules1/sdss/dr7sky/fits/"
dataFile = "sky-patches.fits"
outDir = "/var/www/html/sdss3/skychop/sdss-tmp/"
tableData = pf.open(dataFile)[1].data
clipXYCen = []

RADEC_list = ic.findClosestCenters(RADeg, decDeg, tableData, xSize, ySize)
#closestRA,closestDEC,closestOff = RADEC_list[0]
#closestFileName, closestFileDir = ic.getFileName(closestRA, closestDEC, fitsPath)

rectListx,rectListy = [],[]
for cutPt in [(RADeg+xSize/2.0,decDeg+ySize/2.0),(RADeg-xSize/2.0,decDeg+ySize/2.0),(RADeg+xSize/2.0,decDeg-ySize/2.0),(RADeg-xSize/2.0,decDeg-ySize/2.0)]:
	mCen1,mCen2,off = ic.findClosestCenters(RADeg, decDeg, tableData, xSize, ySize)[0]
	imName = "turd"
	rectCenter, width, height = ic.cutCorner(cutPt, (mCen1,mCen2), (RADeg, decDeg), imName)
	rectListx.append(rectCenter[0])
	rectListy.append(rectCenter[1])
plt.plot(rectListx,rectListx,'.')
plt.show()
os._exit(0)

if fileDir[len(fileDir) - 1] != "/":
	fileDir = fileDir + "/"

arcFileList = []
for letter in bands:
	ic.gunzipIt(fileName + "-" + letter + ".fits.gz", fileDir+fileName, outDir)
	ic.clipFits(outDir + fileName + "-" + letter + ".fits", RADeg, decDeg, size, outDir + fileName + "-" + letter + "-" + str(xSize) +"x"+ str(ySize) + ".fits")
	os.unlink(outDir + fileName + "-" + letter + ".fits")
	arcFileList.append("sdss-tmp/" + fileName + "-" + letter + "-" + str(xSize) +"x"+ str(ySize) + ".fits")

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