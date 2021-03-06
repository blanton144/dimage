#!/usr/bin/env python

import pyfits
import os
import sys
from PGConnection import engine, Session
from ModelClasses import *

afile = os.environ['DIMAGE_DIR']+'/data/atlas/atlas_sample.fits'
agal= fitsio.read(afile)

session = Session()

keys=None
nsaid=0
for cgalaxy in agal:
    s = atlas()
    elems= [x for x in dir(s) if x[0] != '_' and x != 'nsaid' and x != 'atlas_pk' and x != 'metadata']
    for elem in elems:
        setattr(s, elem, str(cgalaxy.field(elem)))
    setattr(s, 'nsaid', str(nsaid))
    session.add(s)
    session.commit()
    nsaid=nsaid+1L

engine.dispose() # cleanly disconnect from the database
sys.exit(0)




