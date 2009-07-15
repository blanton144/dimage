#
#  test_js_timer.py
#  dimage
#
#  Created by Adrian Price-Whelan on 7/15/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

import time

testfile = open("sdss-tmp/testfile.txt","w")
print "Processing..." > testfile
time.sleep(5)
print "This is the 1st line" > testfile
time.sleep(10)
print "This is the 2nd line" > testfile
time.sleep(10)
print 0 > testfile
testfile.close()