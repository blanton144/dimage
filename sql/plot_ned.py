#!/usr/bin/python

import pyfits
import os
import sys
import sqlalchemy
from PGConnection import engine, Session
from ModelClasses import *
import matplotlib.pyplot as plt

session= Session()

radec = session.query(ned.ra, ned.dec).all()
ra= [x[0] for x in radec]
dec= [x[1] for x in radec]

engine.dispose()


plt.plot(ra,dec,',')
plt.show()
