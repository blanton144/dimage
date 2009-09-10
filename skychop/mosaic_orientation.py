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

rectListx,rectListy,rectList = [],[],[]

targetImgCorners = [(RADeg + (xSize/2.0)/np.cos(decDeg*pi/180.0),decDeg+ySize/2.0),(RADeg - (xSize/2.0)/np.cos(decDeg*pi/180.0),decDeg+ySize/2.0), \
					(RADeg + (xSize/2.0)/np.cos(decDeg*pi/180.0),decDeg-ySize/2.0),(RADeg - (xSize/2.0)/np.cos(decDeg*pi/180.0),decDeg-ySize/2.0)]
# Respective opposite corners to the above
oppositeImgCorners = targetImgCorners[::-1]

for i in range(len(targetImgCorners)):
	imName = "test"
	rectCenter, rectSize = ic.cutSection(targetImgCorners[i], oppositeImgCorners[i], ic.findClosestCenter(targetImgCorners[i][0],targetImgCorners[i][1],tableData),(RADeg,decDeg), (xSize, ySize))
	rectList.append((rectCenter[0],rectCenter[1],rectSize[0],rectSize[1]))
	rectListx.append(rectCenter[0])
	rectListy.append(rectCenter[1])

foundX, foundY = ic.findClosestCenter(RADeg,decDeg,tableData)
for i in range(np.shape(tableData)[0]):
	if ic.dist((tableData[i][0],tableData[i][1]),(foundX,foundY)) <= 3.0:
		pl.plot([tableData[i][0]], [tableData[i][1]],'b.', ms=5.0)
		pl.plot([tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1])),tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1]))],[tableData[i][1]-0.5,tableData[i][1]+0.5],'b')
		pl.plot([tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1])),tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1]))],[tableData[i][1]+0.5,tableData[i][1]+0.5],'b')
		pl.plot([tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1])),tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1]))],[tableData[i][1]+0.5,tableData[i][1]-0.5],'b')
		pl.plot([tableData[i][0]+(0.5/np.cos(pi/180.0*tableData[i][1])),tableData[i][0]-(0.5/np.cos(pi/180.0*tableData[i][1]))],[tableData[i][1]-0.5,tableData[i][1]-0.5],'b')

for i in range(4):
	pl.plot([rectList[i][0]-rectList[i][2],rectList[i][0]-rectList[i][2]],[rectList[i][1]-rectList[i][3],rectList[i][1]+rectList[i][3]],'k')
	pl.plot([rectList[i][0]-rectList[i][2],rectList[i][0]+rectList[i][2]],[rectList[i][1]+rectList[i][3],rectList[i][1]+rectList[i][3]],'k')
	pl.plot([rectList[i][0]+rectList[i][2],rectList[i][0]+rectList[i][2]],[rectList[i][1]+rectList[i][3],rectList[i][1]-rectList[i][3]],'k')
	pl.plot([rectList[i][0]+rectList[i][2],rectList[i][0]-rectList[i][2]],[rectList[i][1]-rectList[i][3],rectList[i][1]-rectList[i][3]],'k')

pl.plot([rectListx[0]],[rectListy[0]],'y.',ms=10)
pl.plot([rectListx[1]],[rectListy[1]],'c.',ms=10)
pl.plot([rectListx[2]],[rectListy[2]],'m.',ms=10)	
pl.plot([rectListx[3]],[rectListy[3]],'r.',ms=10)	#**
pl.plot([RADeg],[decDeg],'r.', ms=10.0)
pl.plot([RADeg-(xSize/2)/np.cos(pi/180.0*decDeg),RADeg-(xSize/2)/np.cos(pi/180.0*decDeg)],[decDeg-(ySize/2),decDeg+(ySize/2)],'r')
pl.plot([RADeg-(xSize/2)/np.cos(pi/180.0*decDeg),RADeg+(xSize/2)/np.cos(pi/180.0*decDeg)],[decDeg+(ySize/2),decDeg+(ySize/2)],'r')
pl.plot([RADeg+(xSize/2)/np.cos(pi/180.0*decDeg),RADeg+(xSize/2)/np.cos(pi/180.0*decDeg)],[decDeg+(ySize/2),decDeg-(ySize/2)],'r')
pl.plot([RADeg+(xSize/2)/np.cos(pi/180.0*decDeg),RADeg-(xSize/2)/np.cos(pi/180.0*decDeg)],[decDeg-(ySize/2),decDeg-+(ySize/2)],'r')
pl.axis([(RADeg-1.0),(RADeg+1.0),decDeg-1.0,decDeg+1.0])
pl.show()