"""
Calculate an approximate

Michael R. Blanton, 2014-05-14
"""

import numpy as np
from scipy import interpolate
import matplotlib.pyplot as plt

def curve2image(radius, sb, nx, ny, ba=1., phi=0., xcen=None, ycen=None):
    """Converts an elliptical surface brightness distribution to an image.
    
    Parameters
    ----------
    radius : 1-D ndarray with radii
    sb : 1-D ndarray with surface brightness
    nx : x size of image
    ny : y size of image
    ba : axis ratio (b/a) between 0.2 and 1 (default 1)
         (if input < 0.2 then 0.2 is used)
    phi : position angle in deg (default 0)
         (direction of major axis, defined s.t. tan(phi) = -x/y)
    xcen : X center to use (default float(nx)*0.5)
    ycen : Y center to use (default float(ny)*0.5)
    nfilter : number of pixels to filter over for surface brightness
              (must be odd)
    ofilter : order of Salizsky-Golay filter
    petrorad : if not None, uses this Petrosian radius by fiat (default None)
    forceflux : if not None, assumes this for total flux and only calculates 
                r50 and r90

    Returns
    -------
    image : [nx, ny]
      array with image in it
      
    Notes
    -----
    The resulting image has an axis ratio and position angle as input,
    with the given surface brightness distribution. 

    For a North-up (+y), East-left (-x) image, position angle phi 
    definition corresponds to astronomical standard (deg East of North).
    
    """
    # Interpret input
    PI=3.14159265358979
    if(xcen is None): 
        xcen=float(nx)*0.5
    if(ycen is None): 
        ycen=float(ny)*0.5
    if(ba > 0.2):
        ba_use= ba
    else:
        ba_use= 0.2

    # Create radius array defining how far pixels are from center, 
    # accounting for axis ratio.
    x= np.outer(np.ones(nx),np.arange(ny))
    x= x-xcen
    y= np.outer(np.arange(nx),np.ones(ny))
    y= y-ycen
    xp= (np.cos(PI/180.*phi)*x - np.sin(PI/180.*phi)*y)/ba_use
    yp= (np.sin(PI/180.*phi)*x + np.cos(PI/180.*phi)*y)
    rimage= np.sqrt(xp**2+yp**2)

    # Now create image
    sb= np.insert(sb, 0, sb[0])
    radius= np.insert(radius, 0, np.array([0.], dtype=radius.dtype))
    interper=interpolate.interp1d(radius, sb)
    indx= np.nonzero(rimage.flat < max(radius)-1)
    image= np.zeros(nx*ny)
    image[indx]= interper(rimage.flat[indx])
    image=image.reshape((nx, ny))

    image= np.float32(image)
    return image 
 
