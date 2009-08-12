#! /usr/bin/env python

import Image
import pyfits
import numpy as np
from scipy.stats import scoreatpercentile
import sys

def asinhScale(inputArray, scale_min=None, scale_max=None, non_linear=2.0):
	imageData=np.array(inputArray, copy=True)
	
	if scale_min == None:
		scale_min = imageData.min()
	if scale_max == None:
		scale_max = imageData.max()

	factor = np.arcsinh((scale_max - scale_min)/non_linear)
	indices0 = np.where(imageData < scale_min)
	indices1 = np.where((imageData >= scale_min) & (imageData <= scale_max))
	indices2 = np.where(imageData > scale_max)
	imageData[indices0] = 0.0
	imageData[indices2] = 1.0
	imageData[indices1] = np.arcsinh((imageData[indices1] - scale_min) / non_linear) / factor
	return imageData

beta = 0.8
file = sys.argv[1]
pid = sys.argv[2]

dataArray = pyfits.open(file)[0].data
image = Image.fromarray((255.0*asinhScale(dataArray, scale_max=scoreatpercentile(dataArray.ravel(),100.0), non_linear=beta)).astype('UInt8'), 'L')
image = image.resize((400,400),Image.BICUBIC)
image = image.transpose(Image.FLIP_TOP_BOTTOM)
image.save("%s-asinh.png" % pid)
print "%s-asinh.png" % pid
