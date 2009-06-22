#!/usr/local/epd/bin/python
#
# Cuts out a square region from a .fits file and saves it out as a .fits file

import sys
import os
os.environ['HOME'] = '/var/www/html/sdss3/skychop/'
from astLib import astCoords
from astLib import astImages
from astLib import astWCS
import pyfits

# Turn on error messages
astImages.REPORT_ERRORS=True

if len(sys.argv) < 6:
	print "Run: % clipfits.py <tmp subdirectory> <input .fits image> <RADeg> <decDeg> <clip size> <output .fits>"
else:
	subDir=sys.argv[1]
	inFileName=sys.argv[2]
	RADeg=float(sys.argv[3])
	decDeg=float(sys.argv[4])
	clipSizeDeg=float(sys.argv[5])
	outFileName=sys.argv[6]

	img=pyfits.open(subDir + "/" + inFileName)

	# Sometimes images (like some in the INT-WFS) don't have the image data in extension [0]
	# So here we search through the extensions until we find 2D image data
	fitsExtension=None
	for i in range(len(img)):
		if img[i].header['naxis']==2:
			fitsExtension=i
			break

	if fitsExtension==None:
		print "ERROR: ", subDir + "/" + inFileName, "contains no image data. Skipping ..." 

	else:
		imgData=img[fitsExtension].data
		imgWCS=astWCS.WCS(subDir + "/" + inFileName, fitsExtension)

		clipped = astImages.clipImageSectionWCS(imgData, imgWCS, RADeg, decDeg, clipSizeDeg)
		astImages.saveFITS(subDir + "/" + outFileName, clipped['data'], clipped['wcs'])

	