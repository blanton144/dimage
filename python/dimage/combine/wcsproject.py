"""
Reproject an image at a new set of RA and Dec positions, based on a
WCS header. 

Michael R. Blanton, 2015-02-04
"""

import os
import numpy as np
import dimage
import astropy


def wcsproject(image, weight, wcs, ra, dec, kernel='lanczos', dampsinc=2.47,
               lanczos=2.):
    """Resamples a two-dimensional ndarray image in RA, Dec

    Parameters
    ----------
    image : [nx, ny] 2-D ndarray
    weight : [nx, ny] weight 2-D ndarray
    wcs : WCS object
    ra, dec : [N] locations for samples
    kernel : Kernel to use in resampling (default 'dampsinc')
    dampsinc : Gaussian scale used for 'dampsinc' (default 2.47)
    lanczos : Lanczos scale parameter "a" (default 2)

    Returns
    -------
    samples, weights, inbox : [M] samples, weights, and indices into ra,dec

    Notes
    -----
    Calls dresample.
    Will NOT work for very wide angle input images (180. deg or more), because  
     0/360 case checking is too simple.
    """

    # Make sure RA/Dec are flat
    ra_flat = ra.flatten()
    dec_flat = dec.flatten()

    # Find bounding box of image in RA/Dec and get indices
    # of ra/dec grid within that box
    try:
        ft = wcs.calc_footprint()
    except AttributeError:
        ft = wcs.calcFootprint()
    xy = wcs.all_world2pix(ft, 0)
    radec = wcs.all_pix2world(xy[:, 0], xy[:, 1], 0)
    ramin = ft[:, 0].min()
    ramax = ft[:, 0].max()
    decmin = ft[:, 1].min()
    decmax = ft[:, 1].max()
    if(ramax - ramin > 180.):
        # Case that image straddles 0/360. (
        inbox= (np.nonzero(((ra_flat<ramin) | (ra_flat>ramax)) &
                           (dec_flat>decmin) & (dec_flat<decmax)))[0]
    else:
        # Case that image doesn't straddle
        inbox= (np.nonzero((ra_flat>ramin) & (ra_flat<ramax) &
                          (dec_flat>decmin) & (dec_flat<decmax)))[0]

    # Bail if no pixels
    if(len(inbox) == 0):
        return(None, None, inbox)
            
    # Get X and Y for points within bounding box
    (y,x)= wcs.all_world2pix(ra_flat[inbox], dec_flat[inbox], 0)

    # Actually resample. 
    # (Could be somewhere more efficient if dresample took image 
    # and weight simultaneously.)
    rimage= dimage.resample(image, x, y, kernel=kernel, dampsinc=dampsinc,
                             lanczos=lanczos)
    rweight= dimage.resample(weight, x, y, kernel=kernel, dampsinc=dampsinc,
                              lanczos=lanczos)

    return (rimage, rweight, inbox)
