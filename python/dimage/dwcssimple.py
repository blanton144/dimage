"""
Create a simple TAN projection astropy WCS object centered
on a given RA/Dec; also returns pixel size. 

Michael R. Blanton, 2015-02-04
"""

import os
import numpy as np
import astropy.wcs as wcs

def sayhi():
    print("hello, this works")
    return

def dwcssimple(ra, dec, size, pixscale):
    """Create simple astropy WCS object, with TAN projection
    
    Parameters
    ----------
    ra, dec : center of image (J2000 deg)
    size : size of square image (deg)
    pixelscale : pixel scale (arcsec)

    Returns
    -------
    (wcs, nx, ny) : WCS object and dimensions of image

    Notes
    -----
    Return North (+y), East (+x) image; no rotation.

    """

    w= wcs.WCS(naxis=2)
    naxis1= np.int32(size/(pixscale/3600.))
    naxis2= naxis1
    xmid= naxis1//2
    ymid= naxis2//2
    w.wcs.crpix = [xmid, ymid]
    w.wcs.cdelt = np.array([pixscale/3600., pixscale/3600.])
    w.wcs.crval = [ra, dec]
    w.wcs.ctype = ["RA---TAN", "DEC--TAN"]

    return (w, naxis1, naxis2)
