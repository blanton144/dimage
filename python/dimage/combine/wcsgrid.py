"""
Create a grid of RA/Dec corresponding to WCS pixels

Michael R. Blanton, 2015-02-04
"""

import numpy as np


def wcsgrid(wcs, nx, ny):
    """Create grid of RA/Dec corresponding to WCS pixels

    Parameters
    ----------
    wcs : WCS
        WCS definition
    nx, ny : size of image referred to in each dimension

    Returns
    -------
    (ra, dec) : np.float32
        each member of tuple is [nx,ny] grid of RA/Decs for each pixel

    """

    # Create x/y image
    x = np.outer(np.arange(nx), np.ones(ny)).flatten()
    y = np.outer(np.ones(nx), np.arange(ny)).flatten()
    xy = np.array([y, x]).transpose()

    # Run through WCS to get RA/Dec values
    radec = wcs.all_pix2world(xy, 0)
    ra = radec[:, 0].reshape((nx, ny))
    dec = radec[:, 1].reshape((nx, ny))

    return (ra, dec)
