"""
Package for measurements on images.

Includes functions for elliptical Petrosian quantities:

 - petro(): calculates elliptical Petrosian quantities
 - apcorr(): calculates aperture corrections to Petrosian quantities
 - curve2image(): utility used by apcorr()


"""

from apcorr import *
from curve2image import *
from petro import *
from sigma import *
from simplexy import *
