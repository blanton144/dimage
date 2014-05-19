"""
Module with tools to calculate the Petrosian fluxes and radii for an image. 

Michael R. Blanton, 2014-05-14
"""

import numpy as np
from scipy import interpolate
from astroML import filters

def petro(image, ba=1., phi=0., xcen=None, ycen=None, petroratio0=0.2, 
          npetro=2., minpetrorad=10., nfilter=201, ofilter=3, 
          petrorad=None, forceflux=None):
    """Calculates Petrosian quantities for an image, returning dict of parameters
    
    Parameters
    ----------
    image : 2-D ndarray 
    ba : axis ratio (b/a) between 0 and 1 (default 1)
    phi : position angle in deg (default 0)
         (direction of major axis, defined s.t. tan(phi) = -x/y)
    petroratio0 : limit to use for Petrosian ratio to define radius
    minpetrorad : minimum Petrosian radius to use (default 10.)
    npetro : number of Petrosian radii for aperture definition
    xcen : X center to use (default center of image)
    ycen : Y center to use (default center of image)
    nfilter : number of pixels to filter over for surface brightness
              (must be odd)
    ofilter : order of Salizsky-Golay filter
    petrorad : if not None, uses this Petrosian radius by fiat (default None)
    forceflux : if not None, assumes this for total flux and only calculates 
                r50 and r90

    Returns
    -------
    filename : string
      File name for the corresponding dust model, or None if non-existent. 
      
    Notes
    -----
    For a North-up (+y), East-left (-x) image, position angle phi 
    definition corresponds to astronomical standard (deg East of North).
    
    """
    # Interpret input
    PI=3.14159265358979
    nx=image.shape[0]
    ny=image.shape[1]
    if(xcen is None): 
        xcen=float(nx)*0.5
    if(ycen is None): 
        ycen=float(ny)*0.5

    # Set default return
    rdict=dict()
    rdict['flux']=-9999.
    rdict['rad']=-9999.
    rdict['r50']=-9999.
    rdict['r90']=-9999.

    # Create radius array defining how far pixels are from center, 
    # accounting for axis ratio.
    x= np.outer(np.ones(nx),np.arange(ny))
    x= x-xcen
    y= np.outer(np.arange(nx),np.ones(ny))
    y= y-ycen
    xp= (np.cos(PI/180.*phi)*x - np.sin(PI/180.*phi)*y)/ba
    yp= (np.sin(PI/180.*phi)*x + np.cos(PI/180.*phi)*y)
    r2= xp**2+yp**2
    
    # Sort the pixels by that radius, storing the pixel flux, 
    # the pixel index, and the radius of the pixel
    isort= np.argsort(r2, axis=None)
    pix=image.flat[isort]
    ipix= np.arange(len(pix))
    radius= np.sqrt(r2.flat[isort])

    # Find surface brightness, enclosed flux, mean surface brightness, 
    # and Petrosian ratio
    sb= filters.savitzky_golay(pix, nfilter, ofilter)
    flux= np.cumsum(pix)
    meansb= flux/(ipix+1.)
    petroratio= sb/meansb

    # Get the Petrosian ratio, if it is not given
    if(petrorad is None and forceflux is None):
        ratiop0= petroratio0+np.zeros(len(petroratio))
        ibelow= np.nonzero((petroratio < ratiop0) * (radius > minpetrorad))
        petrorad= radius[np.min(ibelow)]

    # Now get the Petrosian fluxes
    if(forceflux is None):
        aprad= petrorad*npetro
        if(aprad>max(radius)):
            aprad=max(radius)
        interper= interpolate.interp1d(radius, flux)
        petroflux=interper(aprad)
    else:
        petroflux=forceflux
        irad=np.arange(flux.argmax())
        if(petroflux>0. and petroflux < max(flux[irad])):
            interper= interpolate.interp1d(flux[irad], radius[irad])
            print petroflux 
            print max(flux[irad]) 
            aprad= interper(petroflux)
            petrorad=aprad/npetro

    # Given the Petrosian fluxes, get the 50% and 90% light radii
    if(petroflux>0. and petroflux < max(flux)):
        irad= np.nonzero(radius<aprad)
        interper= interpolate.interp1d(flux[irad], radius[irad])
        petror50=interper(petroflux*0.5)
        petror90=interper(petroflux*0.9)
    else:
        petror50=-9999.
        petror90=-9999.
        
    rdict['flux']=petroflux
    rdict['rad']=petrorad
    rdict['r50']=petror50
    rdict['r90']=petror90

    return rdict
