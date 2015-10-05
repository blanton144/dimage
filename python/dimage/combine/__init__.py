"""
Tools to combine a desired set of images onto a common footprint.
Can use various resampling kernels; see documentation for dresample.

Notes and to-do:
----------------

 - Does not adjust for pixel area changes; keeps image in whatever units
   it was input in.
 - Uses simple TAN projection and square image; doesn't yet take arbitrary
   WCS inputs.
 - Will fail on images which span > 180 deg in RA, due to simplistic
   handling of 0/360 boundary

"""

from combine import *
from combine_wise import *
from resample import *
from wcsgrid import *
from wcsproject import *
