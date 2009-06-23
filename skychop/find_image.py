#!/usr/local/epd/bin/python
#
#  find_image.py
#  dimage_py
#
#  Created by Adrian Price-Whelan on 6/3/09.
#  Copyright (c) 2009. All rights reserved.
#

import image_chop as ic
import sys
import gzip
import string

RADeg = float(sys.argv[1])
decDeg = float(sys.argv[2])

fileName, fileDir = ic.findClosestCenter(RADeg, decDeg)
print fileDir + " " + fileName