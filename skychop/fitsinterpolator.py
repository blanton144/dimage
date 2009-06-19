#
#  fitsinterpolator.py
#
#  Created by Adrian Price-Whelan on 6/18/09.
#

import pyfits as pf
import numpy as np
import Image as im

def sincInterpolate(data, xSh, ySh):
	return data

# Globals
subImageSize = (25,25)
subImageCenter = (60,60)
shiftX = 0.5
shiftY = 0.5

imgData = np.random.rand(100,100)
interData = sincInterpolate(imgData, shiftX, shiftY)

print "-------------------"
print "-------------------"
print "-------------------"
print "Original Data:"
print imgData[5:8,5:8]
print ""
print "Interpolated Data:"
print interData[5:8,5:8]