#! /usr/bin/env python

import Image
import pyfits
import numpy as np
from scipy.stats import scoreatpercentile
import sys

def asinhScale(inputArray, scale=5, non_linear=3):
	imageData = np.array(inputArray, copy=True)
	
	imageData = np.arcsinh(imageData * scale * non_linear) / non_linear
	indices0 = np.where(imageData < 0.0)
	indices2 = np.where(imageData > 1.0)
	imageData[indices0] = 0.0
	imageData[indices2] = 1.0
	return imageData

file = sys.argv[1]
pid = sys.argv[2]

dataArray = pyfits.open(file)[0].data
image = Image.fromarray(255.0*asinhScale(dataArray).astype('UInt8'), 'L')
image = image.resize((400,400),Image.BICUBIC)
image = image.transpose(Image.FLIP_TOP_BOTTOM)
image.save("%s-asinh.png" % pid)
print "%s-asinh.png" % pid
