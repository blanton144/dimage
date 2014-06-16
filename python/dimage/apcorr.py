"""
Calculate an approximate

Michael R. Blanton, 2014-05-14
"""

import gc
import numpy as np
from scipy.ndimage import filters
from scipy.signal import fftconvolve
import dimage
import matplotlib.pyplot as plt

def apcorr(radius, sb, aprad, psf, ba=1., phi=0.):
    """Calculates an aperture correction given elliptical profile
    
    Parameters
    ----------
    radius : 1-D ndarray with radii in pixels
    sb : 1-D ndarray with surface brightness
    aprad : aperture radius, in pixels 
    psf : 2-D ndarray with PSF to calculate for
    ba : axis ratio (b/a) between 0 and 1 (default 1)
    phi : position angle in deg (default 0)
         (direction of major axis, defined s.t. tan(phi) = -x/y)

    Returns
    -------
    apcorr : correction factor to apply to PSF-convolved flux for this aperture

    Notes
    -----
    For a North-up (+y), East-left (-x) image, position angle phi 
    definition corresponds to astronomical standard (deg East of North).
    
    """

    # Make image
    factor=1.5
    nx= int(aprad*factor/2.)*2+1
    if(nx < 71):
        nx= 71
    ny= nx
    xcen= np.float32(nx/2)
    ycen= np.float32(ny/2)
    gc.collect()
    print dimage.memory()
    image= dimage.curve2image(radius, sb, nx, ny, 
                              xcen= xcen, ycen=ycen, 
                              ba=ba, phi=phi)
    print "here"
    gc.collect()
    print dimage.memory()
    ivar= np.ones(image.shape, dtype=np.float32)
    print "here0"
    gc.collect()
    print dimage.memory()

    # Measure image
    petro_orig= dimage.petro(image, ivar, ba=ba, phi=phi,
                             xcen=xcen, ycen=ycen,
                             npetro=1., petrorad=aprad)
    print "here1"
    gc.collect()
    print dimage.memory()

    # Convolve image with PSF
    psf2= np.float32(psf)
    cimage= fftconvolve(image, psf2, mode='same')
    help(cimage)
    print "here2"
    gc.collect()
    print dimage.memory()

    # Measure convolved image
    petro_convolved= dimage.petro(cimage, ivar, ba=ba, phi=phi,
                                  xcen=xcen, ycen=ycen,
                                  npetro=1., petrorad=aprad)
    print "here3"
    gc.collect()
    print dimage.memory()

    if(petro_orig['flux'] == -9999.):
        return -9999.
    if(petro_convolved['flux'] == -9999.):
        return -9999.
    if(petro_convolved['flux'] == 0.):
        return -9999.

    apcorr= petro_orig['flux']/petro_convolved['flux']
    print "here4"
    gc.collect()
    print dimage.memory()
    
    return apcorr 
