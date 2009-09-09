#
#  mosaic_orientation.py
#  dimage_py
#
#  Created by Adrian Price-Whelan on 6/18/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

import pyfits as pf
import numpy as np
import matplotlib.pyplot as pl
import sys
import image_chop as ic
from math import fabs, pi
import os

tableData = pf.open("sky-patches.fits")[1].data
RADeg = float(sys.argv[1])
decDeg = float(sys.argv[2])
xSize = float(sys.argv[3])
ySize = float(sys.argv[4])
	
# RADEC_list format: (RA, Dec, offset)
RADEC_list = ic.findClosestCenters(RADeg, decDeg, tableData, xSize, ySize)

rectListx,rectListy = [],[]

targetImgCorners = [(RADeg + (xSize/2.0)/np.cos((decDeg+ySize/2.0)*pi/180.0),decDeg+ySize/2.0),(RADeg - (xSize/2.0)/np.cos((decDeg+ySize/2.0)*pi/180.0),decDeg+ySize/2.0), \
					(RADeg + (xSize/2.0)/np.cos((decDeg-ySize/2.0)*pi/180.0),decDeg-ySize/2.0),(RADeg - (xSize/2.0)/np.cos((decDeg-ySize/2.0)*pi/180.0),decDeg-ySize/2.0)]
# Respective opposite corners to the above
oppositeImgCorners = targetImgCorners[::-1]

for i in range(len(targetImgCorners)):
	imName = "test"
	rectCenter, rectOppCorner = ic.cutSection(targetImgCorners[i], oppositeImgCorners[i], ic.findClosestCenter(targetImgCorners[i][0],targetImgCorners[i][1],tableData),(RADeg,decDeg), (xSize, ySize))
	rectListx.append(rectCenter[0])
	rectListy.append(rectCenter[1])

foundX, foundY = ic.findClosestCenter(RADeg,decDeg,tableData)
for i in range(np.shape(tableData)[0]):
	if ic.dist((tableData[i][0],tableData[i][1]),(foundX,foundY)) < 2.0:
		pl.plot([tableData[i][0]], [tableData[i][1]],'b.', ms=5.0)
		"""pl.plot([tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1]-0.5)),tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1]+0.5))],[tableData[i][1]-0.5,tableData[i][1]+0.5],'b')
		pl.plot([tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1]+0.5)),tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1]+0.5))],[tableData[i][1]+0.5,tableData[i][1]+0.5],'b')
		pl.plot([tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1]+0.5)),tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1]-0.5))],[tableData[i][1]+0.5,tableData[i][1]-0.5],'b')
		pl.plot([tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1]-0.5)),tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1]-0.5))],[tableData[i][1]-0.5,tableData[i][1]-0.5],'b')"""
		pl.plot([tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][0]-0.5)),tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1]+0.5))], \
			[tableData[i][1]-0.5,tableData[i][1]+0.5],'b')
		pl.plot([tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][0]+0.5)),tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1]+0.5))], \
			[tableData[i][1]+0.5,tableData[i][1]+0.5],'b')
		pl.plot([tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][0]+0.5)),tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1]-0.5))], \
			[tableData[i][1]+0.5,tableData[i][1]-0.5],'b')
		pl.plot([tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][0]-0.5)),tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1]-0.5))], \
			[tableData[i][1]-0.5,tableData[i][1]-0.5],'b')

#print "RA:",foundX, "Dec:", foundY
#for i in range(np.shape(tableData)[0]):
#	pl.text(tableData[i][0], tableData[i][1], "RA: %.2f,Dec: %.2f" % (tableData[i][0],tableData[i][1]),fontsize=8)
pl.plot([RADeg],[decDeg],'r.', ms=10.0)

pl.plot([RADeg-(xSize/2),RADeg-(xSize/2)],[decDeg-(ySize/2),decDeg+(ySize/2)],'r')
pl.plot([RADeg-(xSize/2),RADeg+(xSize/2)],[decDeg+(ySize/2),decDeg+(ySize/2)],'r')
pl.plot([RADeg+(xSize/2),RADeg+(xSize/2)],[decDeg+(ySize/2),decDeg-(ySize/2)],'r')
pl.plot([RADeg+(xSize/2),RADeg-(xSize/2)],[decDeg-(ySize/2),decDeg-+(ySize/2)],'r')
pl.plot(rectListx,rectListy,'g.',ms=10.0)
pl.axis([(RADeg-1),(RADeg+1),decDeg-1,decDeg+1])
pl.show()