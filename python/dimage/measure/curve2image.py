"""
Calculate an approximate

Michael R. Blanton, 2014-05-14
"""

import numpy as np
from scipy import interpolate


def curve2image(radius, sb, nx, ny, ba=1., phi=0., xcen=None, ycen=None):
    """Converts an elliptical surface brightness distribution to an image.

    Parameters
    ----------
    radius : np.float32
        1-D ndarray with radii
    sb : np.float32
        1-D ndarray with surface brightness
    nx : int
        x size of image
    ny : int
        y size of image
    ba : float
        axis ratio (b/a) between 0.2 and 1 (default 1); if input < 0.2
        then 0.2 is used.
    phi : float
        position angle in deg (default 0); direction of major axis,
        is defined such that tan(phi) = -x/y
    xcen : float
        X center to use (default float(nx)*0.5)
    ycen : float
        Y center to use (default float(ny)*0.5)

    Returns
    -------
    image : np.float32
        [nx, ny] 2-D array with image in it

    Notes
    -----
    The resulting image has an axis ratio and position angle as input,
    with the given surface brightness distribution.

    For a North-up (+y), East-left (-x) image, position angle phi
    definition corresponds to astronomical standard (deg East of North).
    """
    # Interpret input
    if(xcen is None):
        xcen = float(nx) * 0.5
    if(ycen is None):
        ycen = float(ny) * 0.5
    if(ba > 0.2):
        ba_use = ba
    else:
        ba_use = 0.2

    # Create radius array defining how far pixels are from center,
    # accounting for axis ratio.
    x = np.outer(np.ones(nx), np.arange(ny))
    x = x - xcen
    y = np.outer(np.arange(nx), np.ones(ny))
    y = y - ycen
    xp = ((np.cos(np.pi / 180. * phi) * x -
           np.sin(np.pi / 180. * phi) * y) / ba_use)
    yp = (np.sin(np.pi / 180. * phi) * x + np.cos(np.pi / 180. * phi) * y)
    rimage = np.sqrt(xp**2 + yp**2)

    # Now create image
    sb = np.insert(sb, 0, sb[0])
    radius = np.insert(radius, 0, np.array([0.], dtype=radius.dtype))
    interper = interpolate.interp1d(radius, sb)
    indx = np.nonzero(rimage.flat < max(radius) - 1)
    image = np.zeros(nx * ny)
    image[indx] = interper(rimage.flat[indx])
    image = image.reshape((nx, ny))

    image = np.float32(image)
    return image
