#
#  fitsinterpolator.py
#
#  Created by Adrian Price-Whelan on 6/18/09.
#
import matplotlib.pyplot as pl
import pyfits as pf
import numpy as np
#import Image as im
import scipy.interpolate as sci

"""
x,y = np.mgrid[0:25, 0:25]
imgDataZ = x*y

#interData = sci.interp2d(shImX, shImY, imgDataZ, kind='cubic')
interData = sci.interp2d(x, y,imgDataZ)
"""

z = np.zeros((7,7),dtype=float)
z[3,3] = 1.0
x,y = np.mgrid[0:7,0:7] #for full grid values
ip = sci.interpolate.interp2d(x,y,z,kind='cubic')
xn = np.array([0.3,1.3,2.3,3.3,4.3,5.3,6.3])
yn = np.array([0.3,1.3,2.3,3.3,4.3,5.3,6.3])
print ip(xn,yn)  # interpolated value with call
pl.plot(ip(xn,yn))
pl.show()