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
rectListx,rectListy = [],[]
targetImgCorners = [(RADeg+xSize/2.0,decDeg+ySize/2.0),(RADeg-xSize/2.0,decDeg+ySize/2.0),(RADeg+xSize/2.0,decDeg-ySize/2.0),(RADeg-xSize/2.0,decDeg-ySize/2.0)]
oppositeImgCorners = [(RADeg-xSize/2.0,decDeg-ySize/2.0),(RADeg+xSize/2.0,decDeg-ySize/2.0),(RADeg-xSize/2.0,decDeg+ySize/2.0),(RADeg+xSize/2.0,decDeg+ySize/2.0)]

for i in range(len(targetImgCorners)):
	imName = "test"
	closestCenter = ic.findClosestCenter(targetImgCorners[i][0],targetImgCorners[i][1],tableData)
	rectCenter, rectSize = ic.cutSection(targetImgCorners[i], oppositeImgCorners[i], \
		closestCenter,(RADeg,decDeg), (xSize, ySize), tableData)
	fileName, fileDir = ic.getFileName(closestCenter[0],closestCenter[1], fitsPath)
	arcFileList = []
	for letter in bands:
		ic.gunzipIt(fileName + "-" + letter + ".fits.gz", fileDir+fileName, outDir)
		ic.clipFits(outDir + fileName + "-" + letter + ".fits", rectCenter[0], rectCenter[1], [rectSize[0],rectSize[1]], \
			outDir + fileName + "-clipped-" + str(rectCenter[0])+"_"+str(rectCenter[1]) +  ".fits")
	os.unlink(outDir + fileName + "-" + letter + ".fits")
	#arcFileList.append("sdss-tmp/" + fileName + "-" + letter + "-" + str(xSize) +"x"+ str(ySize) + ".fits")

os._exit(0)

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