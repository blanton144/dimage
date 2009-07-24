#!/usr/local/epd/bin/python
#
#  Created by Adrian Price-Whelan on 7/23/09.
#  Copyright (c) 2009. All rights reserved.
#

import sys
import pyfits as pf
import numpy as np

dataFile = '/var/www/html/sdss3/skychop/sky-patches.fits'
dataFile = 'sky-patches.fits'
tableData = pf.open(dataFile)[1].data
RADeg = float(sys.argv[1])
decDeg = float(sys.argv[2])

offsets = []
yes = 0
for i in range(np.shape(tableData)[0]):
	if np.sqrt((RADeg-tableData[i][0])**2 + (decDeg-tableData[i][1])**2) < np.sqrt(2.0):
		yes = 1
		print yes
		break
	else: pass

if yes == 1:
	pass
else: print 0