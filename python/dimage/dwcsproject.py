"""
Reproject an image at a new set of RA and Dec positions, based on a
WCS header. 

Michael R. Blanton, 2015-02-04
"""

import os
import numpy as np

def dwcsproject(image, wcs, ra, dec, kernel='lanczos', dampsinc=2.47,
                lanczos=2.):
    """Resamples a two-dimensional ndarray image in RA, Dec
    
    Parameters
    ----------
    image : [nx, ny] 2-D ndarray 
    wcs : WCS object
    ra, dec : [N] locations for samples
    kernel : Kernel to use in resampling (default 'dampsinc')
    dampsinc : Gaussian scale used for 'dampsinc' (default 2.47)
    lanczos : Lanczos scale parameter "a" (default 2)

    Returns
    -------
    samples : [N] samples

    Notes
    -----
    Calls dresample
    
    """

    (x,y)= wcs.wcs_world2pix(ra, dec, 0)
    return dresample(image, x.flatten(), y.flatten(), 
                     kernel=kernel, dampsinc=dampsinc,
                     lanczos=lanczos)
