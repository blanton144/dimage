#
#  clean_up.py
#  dimage_py
#
#  Created by Adrian Price-Whelan on 6/15/09.
#

import time as t
import os

home = '/var/www/html/sdss3/apw235/sdss-tmp/'
tmpFiles = os.listdir(home)

tarFileList = []
for file in tmpFiles:
	if (file[-6:] == 'tar.gz') or (file[-4:] == 'fits') or (file[-3:] == 'txt'):
		tarFileList.append(file)
	else: pass

for tarFile in tarFileList:
	cTime = os.stat(home+tarFile).st_ctime
	if (t.time() - cTime) >= 1800.0:
		os.remove(home+tarFile)
	else: pass