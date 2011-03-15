#!/usr/local/python-2.7/bin/python

import pyfits
import os
import sys
import sqlalchemy
import numpy
from PGConnection import engine, Session
from ModelClasses import *

mfile = os.environ['DIMAGE_DIR']+'/data/atlas/atlas_sample_measure.fits'
fhdu= pyfits.open(mfile)
mgal= fhdu[1].data
fhdu.close()

session = Session()

nsaid=0
for cgalaxy in mgal:
    m = measure()
    elems= [x for x in dir(m) if x[0] != '_' and x != 'nsaid' and x != 'measure_pk' and x != 'metadata']
    for elem in elems:
        if((cgalaxy.field(elem)).size==1):
            setattr(m, elem, str(cgalaxy.field(elem)))
        else:
            list=[]
            for x in cgalaxy.field(elem):
                if(abs(x) > 1.e-41):
                    list.append(float(x))
                else:
                    list.append(0.)
            setattr(m, elem, list)
    setattr(m, 'nsaid', str(nsaid))
    session.add(m)
    session.commit()
    nsaid=nsaid+1L

engine.dispose() # cleanly disconnect from the database
sys.exit(0)



