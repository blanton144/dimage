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

RADeg = float(sys.argv[1])
decDeg = float(sys.argv[2])

fileName, fileDir = ic.findClosestCenter(RADeg, decDeg)
print fileDir + " " + fileName

"""
os.system("mkdir /var/www/html/sdss3/apw235/tmp/" + str(thisPID) + "/")

for i in os.listdir(fileDir + fileName):
	os.system("gunzip -c " + fileDir + fileName + "/" + i + " > /var/www/html/sdss3/apw235/tmp/" + str(thisPID) + "/" + i[0:26])
"""