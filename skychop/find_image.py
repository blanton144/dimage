#!/usr/local/epd/bin/python
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
import pyfits as pf
from math import sqrt, fabs, pi
import numpy as np

"""Collect user input in the form of shell arguments"""
RADeg = float(sys.argv[1])
decDeg = float(sys.argv[2])
xSize, ySize = float(sys.argv[3])+0.01,float(sys.argv[4])+0.01
bands = sys.argv[5]
tarName = sys.argv[6]
size = xSize, ySize

"""Constants and other variable declarations"""
fitsPath = "/mount/hercules1/sdss/dr7sky/fits/"													# Server path to FITS data files
dataFile = "/var/www/html/sdss3/skychop/sky-patches.fits"																	# FITS file to read SDSS mosaic center (RA, DEC)
outDir = "/var/www/html/sdss3/skychop/sdss-tmp/"												# Server path to output directory
tableData = pf.open(dataFile)[1].data																# Table of (RA, DEC) values from SDSS mosaics
targetImgCorners = [(RADeg+xSize/2.0,decDeg+ySize/2.0),(RADeg-xSize/2.0,decDeg+ySize/2.0), \
					(RADeg+xSize/2.0,decDeg-ySize/2.0),(RADeg-xSize/2.0,decDeg-ySize/2.0)]		# Corners of the user specified image
oppositeImgCorners = [(RADeg-xSize/2.0,decDeg-ySize/2.0),(RADeg+xSize/2.0,decDeg-ySize/2.0),\
					  (RADeg-xSize/2.0,decDeg+ySize/2.0),(RADeg+xSize/2.0,decDeg+ySize/2.0)]	# Respective opposite corners to the above

clipXYCen = []
rectListx,rectListy = [],[]
arcFileList = {}
swarpCmds = {}
closestCenters = []
allFileNames = None

"""For each of the corners of the user specified target image, find the 
			closest mosaic center to that image. Test to make sure that
			the image is unique, and that it lies outside of the closest
			image to the center of the target image."""
for crnr in targetImgCorners: closestCenters.append(ic.findClosestCenter(crnr[0],crnr[1],tableData))	# Find the closest center to each corner of the target image
#closestCenters = ic.repDupesWithZero(closestCenters)													# Replace any duplicates with a 0 to skip

for i in range(len(closestCenters)):
	if closestCenters[i] == 0: pass
	else:
		oneImEachBand = []
		rectCenter, rectSize = ic.cutSection(targetImgCorners[i], oppositeImgCorners[i], \
			closestCenters[i],(RADeg,decDeg), (xSize, ySize))					# For each subsection of the target image, find the center,x size,y size to give to clipfits
		fileName, fileDir = ic.getFileName(closestCenters[i][0],closestCenters[i][1], fitsPath)			# Get the filename for the closest mosaic to the corner
		
		""" For each band that the user specifies, clip the closest mosaic image down to size and delete the original"""
		for letter in bands:		
			ic.gunzipIt("%s-%s.fits.gz" % (fileName, letter), fileDir+fileName, outDir)
			ic.clipFits(outDir + fileName + "-" + letter + ".fits", rectCenter[0], rectCenter[1], [rectSize[0],rectSize[1]], \
				outDir + fileName + "-clipped-" + letter + "-%.2f_%.2f.fits" % (rectCenter[0], rectCenter[1]))
			os.unlink(outDir + fileName + "-" + letter + ".fits")
			oneImEachBand.append(fileName + "-clipped-" + letter + "-%.2f_%.2f.fits" % (rectCenter[0], rectCenter[1]))
		if allFileNames == None:
			allFileNames = np.array([oneImEachBand])
		else:
			allFileNames = np.append(allFileNames,np.reshape([oneImEachBand],(1,len(bands))),axis=0)
allFileNamesT = allFileNames.transpose()

""" For each clipped subimage in each row (organized by BAND), SWarp the images together"""
if np.shape(allFileNamesT)[1] == 1:
	for k in range(np.shape(allFileNamesT)[0]):
		coaddFname = ic.getIAUFname(RADeg,decDeg) + "-" + bands[k] + "-%.2fx%.2f.fits" % (xSize, ySize)
		swarpKARGS = "-IMAGEOUT_NAME=" + coaddFname + " -WEIGHTOUT_NAME=weight.fits"
		print "%s %s" % (allFileNamesT[k][0], swarpKARGS)
		print coaddFname
else:
	for k in range(np.shape(allFileNamesT)[0]):
		swarpArg =""
		for name in allFileNamesT[k]:
			swarpArg += " %s" % name
		coaddFname = ic.getIAUFname(RADeg,decDeg) + "-" + bands[k] + "-%.2fx%.2f.fits" % (xSize, ySize)
		swarpKARGS = "-IMAGEOUT_NAME=" + coaddFname + " -WEIGHTOUT_NAME=weight.fits"
		print "%s %s" % (swarpArg,swarpKARGS)
		print coaddFname
