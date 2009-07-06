#
#  fitsinterpolator.py
#
#  Created by Adrian Price-Whelan on 6/18/09.
#

import pyfits as pf
import numpy as np
#import Image as im
import scipy.interpolate as sci

x,y = np.mgrid[0:25, 0:25]
imgDataZ = x*y

#interData = sci.interp2d(shImX, shImY, imgDataZ, kind='cubic')
interData = sci.interp2d(x, y,imgDataZ)

print interData(2.6,7.4)