#!/usr/bin/python

import pyfits
import os
import sys
import sqlalchemy
from PGConnection import engine, Session
from ModelClasses import *

filename = os.environ['DIMAGE_DIR']+'/data/atlas/ned_atlas.fits'

fhdu= pyfits.open(filename)
neds= fhdu[1].data

session = Session()

keys=None
for cned in neds:
    s = ned()
    elems= [x for x in dir(s) if x[0] != '_' and x != 'id' and x != 'metadata']
    for elem in elems:
        setattr(s, elem, str(cned.field(elem)))
    session.add(s)
    session.commit()

engine.dispose() # cleanly disconnect from the database
sys.exit(0)



