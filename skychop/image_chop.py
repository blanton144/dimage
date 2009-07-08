#!/usr/local/epd/bin/python
#
# Made it a function, not a stand-alone module
#
# Cuts out a square region from a .fits file and saves it out as a .fits file
#

import os
# Enable this line for testing
#os.environ['HOME'] = '/var/www/html/sdss3/skychop'
#os.environ['HOME'] = '/var/www/html/sdss3/skychop/sdss-tmp'
import numpy as np
import pyfits as pf
from math import fabs
import gzip
from shutil import move
from astLib import astCoords
from astLib import astImages
from astLib import astWCS
import operator

def findClosestCenters(RADeg, decDeg, tableData, xSize, ySize):
	RADEC_list = []
	for i in range(np.shape(tableData)[0]):
		offset = np.sqrt((RADeg-tableData[i][0])**2 + (decDeg-tableData[i][1])**2)
		if offset <= (np.sqrt((xSize/2.0)**2.0+(ySize/2.0)**2.0)+0.5):
			RADEC_list.append((tableData[i][0],tableData[i][1],offset))
	
	sortedList = sorted(RADEC_list, key=operator.itemgetter(2))
	return sortedList
	
def findClosestCenter(RADeg, decDeg, tableData):
	offList = []
	for i in range(np.shape(tableData)[0]):
		offList.append(np.sqrt((RADeg-tableData[i][0])**2 + (decDeg-tableData[i][1])**2))
	theMin = min(offList)
	for j in range(len(offList)):
		if offList[j] == theMin:
			index = j
	print offList[index-1],offList[index],offList[index+1]
	return tableData[index][0], tableData[index][1]

def getFileName(theRA, theDec, fitsPath):
	degRa = theRA / 15.0
	hrRa = int(degRa)
	minRa = (degRa - hrRa) * 60.0
	secRaINT = int((minRa - int(minRa)) * 60.0)
	secRaDECIMAL = ((minRa - int(minRa))*60.0 - secRaINT) * 100.0
	
	degDec = theDec
	minDec = (degDec - int(degDec)) * 60.0
	secDecINT = int((minDec - int(minDec)) * 60.0)
	secDecDECIMAL = ((minDec - int(minDec))*60.0 - secDecINT) * 10.0
	
	if hrRa > 19 or hrRa < 7:
		raise IndexError('<font class="errorText" align="center">RA Out of range</font>')
		os._exit(0)
	if degDec < -4.0 or degDec > 70.0:
		raise IndexError('<font class="errorText" align="center">Dec out of range</font>')
		os._exit(0)
	
	if degDec > 0.0: RADecPath = "%(path)s%(hrRa)02dh/p%(dec)02d/" % {"path":fitsPath,"hrRa":hrRa,"dec":fabs(degDec)}
	else: RADecPath = "%(path)s%(hrRa)02dh/m%(dec)02d/" % {"path":fitsPath,"hrRa":hrRa,"dec":fabs(degDec)}
	
	fileName = "J%(hrRa)02d%(minRa)02d%(secRaINT)02d.%(secRaDECIMAL)02d%(degDec)+03d%(minDec)02d%(secDecINT)02d.%(secDecDECIMAL)01d" % \
		{"hrRa":hrRa,"minRa":minRa,"secRaINT":secRaINT,"secRaDECIMAL":secRaDECIMAL,"degDec":fabs(degDec),"minDec":minDec,"secDecINT":secDecINT,"secDecDECIMAL":secDecDECIMAL}

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