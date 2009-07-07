#!/usr/local/epd/bin/python
#
# Made it a function, not a stand-alone module
#
# Cuts out a square region from a .fits file and saves it out as a .fits file
#

import os
# Enable this line for testing
os.environ['HOME'] = '/var/www/html/sdss3/skychop'
#os.environ['HOME'] = '/var/www/html/sdss3/skychop/sdss-tmp'
import numpy as np
import pyfits as pf
from math import fabs, sqrt
import gzip
from shutil import move
from astLib import astCoords
from astLib import astImages
from astLib import astWCS

def findClosestCenter(RADeg, decDeg):
	tableData = pf.open("sky-patches.fits")[1].data
	oldOffset = None
	for i in range(np.shape(tableData)[0]):
		newOffset = np.sqrt( (RADeg-tableData[i][0])**2 + (decDeg-tableData[i][1])**2 )
		if oldOffset == None:
			oldOffset = np.sqrt( (RADeg-tableData[i][0])**2 + (decDeg-tableData[i][1])**2 )
			index = i
		else:
			if newOffset < oldOffset:
				oldOffset = newOffset
				index = i
	
	# Navigate to the correct directory
	fitsPath = "/mount/hercules1/sdss/dr7sky/fits/"
	RAIntHour = int(tableData[index][0] / 15.0)
	if RAIntHour > 19 or RAIntHour < 7:
		raise IndexError('<font class="errorText" align="center">RA Out of Range</font>')
		os._exit(0)
	
	decTime = tableData[index][0] / 15.0
	decDecl = tableData[index][1]
	
	hr = decTime
	min = (decTime - float(int(decTime))) * 60.0
	secINT = int(( ((decTime - float(int(decTime))) * 60.0) - int((decTime - float(int(decTime))) * 60.0) ) * 60.0)
	secDECIMAL = ( ( ((decTime - float(int(decTime))) * 60.0) - int((decTime - float(int(decTime))) * 60.0) ) * 60.0 - secINT) * 100.0
	
	degDec = int(decDecl)
	minDec = int( (decDecl - float(int(decDecl))) * 60.0 )
	secDecINT = int(( ((decDecl - float(int(decDecl))) * 60.0) - int((decDecl - float(int(decDecl))) * 60.0) ) * 60.0)
	secDecDECIMAL = (( ((decDecl - float(int(decDecl))) * 60.0) - int((decDecl - float(int(decDecl))) * 60.0) ) * 60.0 - secDecINT) * 10.0
	
	if degDec > 0.0: RADecPath = "%(path)s%(RAIntHour)02dh/p%(degg)s/" % {"path":fitsPath,"RAIntHour":RAIntHour,"degg":degDec}
	else: RADecPath = "%(path)s%(RAIntHour)02dh/m%(degg)s/" % {"path":fitsPath,"RAIntHour":RAIntHour,"degg":degDec}
		
	
	fileName = "J%(hr)02d%(min)02d%(secINT)02d.%(secDECIMAL)02d%(degDec)+03d%(minDec)02d%(secDecINT)02d.%(secDecDECIMAL)01d" % \
		{"hr":hr,"min":min,"secINT":secINT,"secDECIMAL":secDECIMAL,"degDec":fabs(degDec),"minDec":minDec,"secDecINT":secDecINT,"secDecDECIMAL":secDecDECIMAL}

	return fileName, RADecPath

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

def clipFits(inFileName, RADeg, decDeg, clipSizeDeg, outFileName):
	img = pf.open(inFileName)
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