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
from math import fabs, sqrt, pi
import gzip
from shutil import move
import operator

def findClosestCenters(RADeg, decDeg, tableData, xSize, ySize):
	RADEC_list = []
	for i in range(np.shape(tableData)[0]):
		offset = np.sqrt((RADeg - tableData[i][0])**2 + (decDeg-tableData[i][1])**2)
		if offset <= (np.sqrt((xSize/2.0)**2.0+(ySize/2.0)**2.0)+0.5):
			RADEC_list.append((tableData[i][0],tableData[i][1],offset))
	
	sortedList = sorted(RADEC_list, key=operator.itemgetter(2))
	return sortedList
	
def findClosestCenter(RADeg, decDeg, tableData):
	offsets = []
	for i in range(np.shape(tableData)[0]):
		offsets.append(np.sqrt((RADeg  - tableData[i][0])**2 + (decDeg-tableData[i][1])**2))
	index = offsets.index(min(offsets))
	return tableData[index][0], tableData[index][1]

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

def getFileName(theRA, theDec, fitsPath):
	degRa = (theRA / 15.0)
	hrRa = int(degRa)
	minRa = (degRa - hrRa) * 60.0
	secRaINT = int((minRa - int(minRa)) * 60.0)
	secRaDECIMAL = ((minRa - int(minRa))*60.0 - secRaINT) * 100.0
	
	degDec = theDec
	minDec = (degDec - int(degDec)) * 60.0
	secDecINT = int((minDec - int(minDec)) * 60.0)
	secDecDECIMAL = ((minDec - int(minDec)) * 60.0 - secDecINT) * 10.0
	
	if hrRa > 19 or hrRa < 7:
		raise IndexError('<font class="errorText" align="center">RA Out of range</font>')
		os._exit(0)
	if degDec < -4.0 or degDec > 70.0:
		raise IndexError('<font class="errorText" align="center">Dec out of range</font>')
		os._exit(0)
	
	if degDec > 0.0:
		if fabs(int(degDec)) % 2 == 0: pathDec = fabs(int(degDec))
		else: pathDec = fabs(int(degDec)) - 1
		RADecPath = "%(path)s%(hrRa)02dh/p%(dec)02d/" % {"path":fitsPath,"hrRa":hrRa,"dec":pathDec}
		fileName = "J%(hrRa)02d%(minRa)02d%(secRaINT)02d.%(secRaDECIMAL)02d%(degDec)+03d%(minDec)02d%(secDecINT)02d.%(secDecDECIMAL)01d" % \
			{"hrRa":hrRa,"minRa":minRa,"secRaINT":secRaINT,"secRaDECIMAL":secRaDECIMAL,"degDec":degDec,"minDec":minDec,"secDecINT":secDecINT,"secDecDECIMAL":secDecDECIMAL}
	else:
		if fabs(int(degDec)) % 2 == 0: pathDec = fabs(int(degDec))
		else: pathDec = fabs(int(degDec)) - 1
		RADecPath = "%(path)s%(hrRa)02dh/m%(dec)02d/" % {"path":fitsPath,"hrRa":hrRa,"dec":pathDec}
		fileName = "J%(hrRa)02d%(minRa)02d%(secRaINT)02d.%(secRaDECIMAL)02d-%(degDec)02d%(minDec)02d%(secDecINT)02d.%(secDecDECIMAL)01d" % \
			{"hrRa":hrRa,"minRa":minRa,"secRaINT":secRaINT,"secRaDECIMAL":secRaDECIMAL,"degDec":fabs(degDec),"minDec":fabs(minDec),"secDecINT":fabs(secDecINT),"secDecDECIMAL":fabs(secDecDECIMAL)}
	return fileName, RADecPath

def getIAUFname(theRA, theDec):
	degRa = theRA / 15.0
	hrRa = int(degRa)
	minRa = (degRa - hrRa) * 60.0
	secRaINT = int((minRa - int(minRa)) * 60.0)
	secRaDECIMAL = ((minRa - int(minRa))*60.0 - secRaINT) * 100.0
	
	degDec = theDec
	minDec = (degDec - int(degDec)) * 60.0
	secDecINT = int((minDec - int(minDec)) * 60.0)
	secDecDECIMAL = ((minDec - int(minDec)) * 60.0 - secDecINT) * 10.0
	
	if hrRa > 19 or hrRa < 7:
		raise IndexError('<font class="errorText" align="center">RA Out of range</font>')
		os._exit(0)
	if degDec < -4.0 or degDec > 70.0:
		raise IndexError('<font class="errorText" align="center">Dec out of range</font>')
		os._exit(0)

	fileName = "J%(hrRa)02d%(minRa)02d%(secRaINT)02d.%(secRaDECIMAL)02d%(degDec)+03d%(minDec)02d%(secDecINT)02d.%(secDecDECIMAL)01d" % \
		{"hrRa":hrRa,"minRa":minRa,"secRaINT":secRaINT,"secRaDECIMAL":secRaDECIMAL,"degDec":fabs(degDec),"minDec":minDec,"secDecINT":secDecINT,"secDecDECIMAL":secDecDECIMAL}

	return fileName

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

""" ALPHA and BETA determine which direction the target corner is in, they act as unit vectors.
	@ Xs are the x values for the border of the mosaic center in the direction of ALPHA, 
		and the border of the sub image in the direction of ALPHA. 
	@ Ys are the y values for the border of the mosaic center in the direction of BETA, 
		and the border of the sub image in the direction of BETA.
	@ XDs finds the distances from the target (sub) image center X value to both Xs.
	@ YDs finds the distances from the target (sub) image center Y value to both Ys.
	@ xInd is the index of XDs of the smaller of the 2 distances.
	@ yInd is the index of YDs of the smaller of the 2 distances.
	@ rectCenter finds the midpoint between the corner of the target image and XDs[xInd], YDs[yInd]."""
def cutSection(tgCnr, opCnr, mosCen, tgCen, size):
	ALPHA,BETA = ((opCnr[0]-tgCnr[0])/fabs(opCnr[0]-tgCnr[0]),(opCnr[1]-tgCnr[1])/fabs(opCnr[1]-tgCnr[1]))
	Xs = [mosCen[0] + (ALPHA/2.0)/np.cos(pi/180.0*mosCen[1]), \ 
		  tgCen[0] + (ALPHA*size[0]/2.0)/np.cos(pi/180.0*tgCen[1])]
	Ys = [mosCen[1] + BETA/2.0, tgCen[1] + (BETA*size[1]/2.0)]
	XDs = [fabs(tgCnr[0]-Xs[0]), fabs(tgCnr[0]-Xs[1])]
	YDs = [fabs(tgCnr[1]-(mosCen[1] + BETA/2.0)), fabs(tgCnr[1]-(tgCen[1] + (BETA*size[1]/2.0)))]
	xInd = XDs.index(min(XDs))
	yInd = YDs.index(min(YDs))
	rectCenter = midpt((tgCnr[0],tgCnr[1]),(Xs[xInd],Ys[yInd]))
	return rectCenter, (fabs(Xs[xInd]-tgCnr[0]),fabs(Ys[yInd]-tgCnr[1]))
	
def clipFits(inFileName, RADeg, decDeg, clipSizeDeg, outFileName):
	from astLib import astCoords
	from astLib import astImages
	from astLib import astWCS
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

def midpt((x,y),(u,v)):
	return ((x+u)/2.0,(y+v)/2.0)
def dist((x,y),(u,v)):
	return sqrt((x-u)**2+(y-v)**2)