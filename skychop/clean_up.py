#
#  clean_up.py
#  dimage_py
#
#  Created by Adrian Price-Whelan on 6/15/09.
#

import time as t
import os

home = '/var/www/html/sdss3/skychop/sdss-tmp/'
tmpFiles = os.listdir(home)

fileList = []
fitstxtList = []
for file in tmpFiles:
	if (file[-6:] == 'tar.gz' or file[-3:] == 'png'):
		fileList.append(file)
	elif  (file[-4:] == 'fits') or (file[-3:] == 'txt'):
		fitstxtList.append(file)
	else: pass

for file in fileList:
	cTime = os.stat(home+file).st_ctime
	if (t.time() - cTime) >= 1800.0:
		os.remove(home+file)
	else: pass
	
for file in fitstxtList:
	cTime = os.stat(home+file).st_ctime
	if (t.time() - cTime) >= 300.0:
		os.remove(home+file)
	else: pass
