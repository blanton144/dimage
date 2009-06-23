#!/usr/local/epd/bin/python
#
# Made it a function, not a stand-alone module
#
# Cuts out a square region from a .fits file and saves it out as a .fits file
#

import os
import pyfits
from math import fabs, sqrt
import gzip
from shutil import move
from astLib import astCoords
from astLib import astImages
from astLib import astWCS
os.environ['HOME'] = '/var/www/html/sdss3/skychop/sdss-tmp'

def findDec(x):
	if fabs(x) == x:
		if int(round(x)) != int(x):
			if int(round(x)) % 2 == 1:
				if (round(x) - 1.0) < 10: return "p0%i" % (round(x) - 1.0)
				else: return "p%i" % (round(x) - 1.0)
			else: 
				if (round(x) - 2.0) < 10: return "p0%i" % (round(x) - 2.0)
				else: return "p%i" % (round(x) - 2.0)
		else:
			if int(round(x)) % 2 == 1:
				if (round(x) - 1.0) < 10: return "p0%i" % (round(x) - 1.0)
				else: return "p%i" % (round(x) - 1.0)
			else: 
				if round(x) < 10: return "p0%i" % round(x)
				else: return "p%i" % round(x)
	else:
		if int(round(x)) != int(x):
			if int(round(x)) % 2 == 1:
				return "m0%i" % (round(x) + 1.0)
			else: 
				return int(round(x) + 2.0)
		else:
			if int(round(x)) % 2 == 1:
				return "m0%i" % (round(x) + 1.0)
			else: 
				return "m0%i" % (round(x))

def findClosestCenter(RADeg, decDeg):
	# Navigate to the correct directory
	fitsPath = "/mount/hercules1/sdss/dr7sky/fits/"
	RAHour = RADeg / 15.0
	RAStr = os.listdir(fitsPath)
	
	for i in RAStr:
		if i == "07h-tmp": pass
		if int(i[0:2]) == int(round(RAHour)):
			RAPath = fitsPath + i[0:2] + "h/"
	RADecPath = RAPath + findDec(decDeg) + "/"
	
	offsetList = []
	for fileName in os.listdir(RADecPath):
		RA = float(fileName[1:3]) + (float(fileName[3:5]) / 60.0) + (float(fileName[5:7]) + float(fileName[8:10]) / 100.0) / 3600.0
		DEC = float(fileName[11:13]) + float(fileName[13:15]) / 60.0 + (float(fileName[15:17]) + float(fileName[18]) / 10.0) / 3600.0
		offsetList.append(sqrt((RA - RAHour)**2.0 + (DEC - decDeg)**2.0))
	
	for i in range(len(offsetList)):
		if offsetList[i] == min(offsetList):
			minOffsetIndex = i
	
	a = os.listdir(RADecPath)
	return a[minOffsetIndex], RADecPath

def gzipIt(file):
	r_file = open(file, 'r')
	w_file = gzip.GzipFile(file + '.gz', 'w', 9)
	w_file.write(r_file.read())
	w_file.flush()
	w_file.close()
	r_file.close()
	os.unlink(file)
	return None

def gunzipIt(file, fileDir, outDir):
	r_file = gzip.GzipFile(fileDir + "/"+file, 'r')
	write_file = fileDir + file[:-3]
	w_file = open(write_file, 'w')
	w_file.write(r_file.read())
	w_file.close()
	r_file.close()
	move(write_file,outDir + file[:-3])
	return None

def clipFits(inFileName, RADeg, decDeg, clipSizeDeg, outFileName):
	img = pyfits.open(inFileName)

	# Sometimes images (like some in the INT-WFS) don't have the image data in extension [0]
	# So here we search through the extensions until we find 2D image data
	fitsExtension=None
	for i in range(len(img)):
		if img[i].header['naxis']==2:
			fitsExtension=i
			break

	if fitsExtension==None:
		print "ERROR: ",inFileName, "contains no image data. Skipping ..." 

	else:
		imgData = img[fitsExtension].data
		imgWCS=astWCS.WCS(inFileName, fitsExtension)

		clipped = astImages.clipImageSectionWCS(imgData, imgWCS, RADeg, decDeg, clipSizeDeg)
		astImages.saveFITS(outFileName, clipped['data'], clipped['wcs'])