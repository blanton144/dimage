#!/usr/local/epd/bin/python
#

homeDir = "/var/www/html/sdss3/skychop/sdss-tmp"

import os
#os.environ['HOME'] = homeDir
os.environ['HOME'] = "/var/www/html/sdss3/skychop/"
from astLib import astCoords
from astLib import astImages
from astLib import astWCS
import apw_utils as apw
from math import fabs
	
def findClosestCenter(RADeg, decDeg, tableData, TBshape):
	offsets = []
	for i in range(TBshape):
		offsets.append( apw.dist((RADeg,tableData[i][0]),(decDeg,tableData[i][1])) )
	index = offsets.index(min(offsets))
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
	else:
		if fabs(int(degDec)) % 2 == 0: pathDec = fabs(int(degDec))
		else: pathDec = fabs(int(degDec)) + 1
		RADecPath = "%(path)s%(hrRa)02dh/m%(dec)02d/" % {"path":fitsPath,"hrRa":hrRa,"dec":pathDec}
	
	fileName = "J%(hrRa)02d%(minRa)02d%(secRaINT)02d.%(secRaDECIMAL)02d%(degDec)+03d%(minDec)02d%(secDecINT)02d.%(secDecDECIMAL)01d" % \
		{"hrRa":hrRa,"minRa":minRa,"secRaINT":secRaINT,"secRaDECIMAL":secRaDECIMAL,"degDec":fabs(degDec),"minDec":minDec,"secDecINT":secDecINT,"secDecDECIMAL":secDecDECIMAL}

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

def cutSection((A,B), (C,D), (U,V), (ALPH,DELT), (xSz,ySz), tableData):
	# A,B = targetCorner
	# C,D = oppositeCorner
	# U,V = closestMosaicCenter
	# ALPH,DELT = targetCenter
	A,B = (float(A),float(B))
	C,D = (float(C),float(D))
	U,V = (float(U),float(V))
	ALPH,DELT = (float(ALPH),float(DELT))
	xSz,ySz = (float(xSz),float(ySz))
	
	KAPPA,BETA = ((C-A)/fabs(C-A),(D-B)/fabs(D-B))
	Xs = [U + KAPPA/2.0,ALPH + (KAPPA*xSz/2.0)]
	Ys = [V + BETA/2.0,DELT + (BETA*ySz/2.0)]
	XDs = [fabs(A-(U + KAPPA/2.0)),fabs(A-(ALPH + (KAPPA*xSz/2.0)))]
	YDs = [fabs(B-(V + BETA/2.0)),fabs(B-(DELT + (BETA*ySz/2.0)))]
	xInd = XDs.index(min(XDs))
	yInd = YDs.index(min(YDs))
	rectCenter = apw.midpt((A,B),(Xs[xInd],Ys[yInd]))
	return rectCenter, (fabs(Xs[xInd]-A),fabs(Ys[yInd]-B))

def clipFits(img, RADeg, decDeg, clipSizeDeg, outFileName):
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