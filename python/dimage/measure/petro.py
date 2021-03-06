import numpy as np
from scipy import interpolate


def petro(image, ivar, ba=1., phi=0., xcen=None, ycen=None, petroratio0=0.2,
          npetro=2., minpetrorad=2., nfilter=11, ofilter=1,
          petrorad=None, forceflux=None, fixmedian=0.):
    """Calculates Petrosian quantities for an image

    Parameters
    ----------
    image : np.float32
        2-D ndarray
    ba : float
        axis ratio (b/a) between 0 and 1 (default 1)
    phi : float
        position angle in deg (default 0); (direction of major axis,
        defined such that tan(phi) = -x/y)
    petroratio0 : float
        limit to use for Petrosian ratio to define radius
    minpetrorad : float
        minimum Petrosian radius to use (default 10.)
    npetro : int
        number of Petrosian radii for aperture definition
    xcen : float
        X center to use (default center of image)
    ycen : float
        Y center to use (default center of image)
    nfilter : int
        number of pixels to filter over for surface brightness (must be odd)
    ofilter : int
        order of Salizsky-Golay filter
    petrorad : float
        if not None, uses this Petrosian radius by fiat (default None)
    forceflux : float
        if not None, assumes this for total flux and only calculates
        r50 and r90

    Returns
    -------
    filename : str
      File name for the corresponding dust model, or None if non-existent.

    Notes
    -----
    For a North-up (+y), East-left (-x) image, position angle phi
    definition corresponds to astronomical standard (deg East of North).

    """
    # Interpret input
    nx = image.shape[0]
    ny = image.shape[1]
    if(xcen is None):
        xcen = float(nx) * 0.5
    if(ycen is None):
        ycen = float(ny) * 0.5
    if(ba > 0.2):
        ba_use = ba
    else:
        ba_use = 0.2

    # Set default return
    rdict = dict()
    rdict['flux'] = -9999.
    rdict['ivar'] = -9999.
    rdict['rad'] = -9999.
    rdict['r50'] = -9999.
    rdict['r90'] = -9999.
    rdict['rbins'] = []
    rdict['rlobins'] = []
    rdict['rhibins'] = []
    rdict['abins'] = []
    rdict['ahibins'] = []
    rdict['alobins'] = []
    rdict['sb'] = []
    rdict['meansb'] = []
    rdict['fbins'] = []
    rdict['fhibins'] = []
    rdict['flobins'] = []
    rdict['vbins'] = []

    # Create radius array defining how far pixels are from center,
    # accounting for axis ratio.
    x = np.outer(np.ones(nx), np.arange(ny))
    x = x - xcen
    y = np.outer(np.arange(nx), np.ones(ny))
    y = y - ycen
    xp = ((np.cos(np.pi / 180. * phi) * x -
           np.sin(np.pi / 180. * phi) * y) / ba_use)
    yp = ((np.sin(np.pi / 180. * phi) * x +
           np.cos(np.pi / 180. * phi) * y))
    r2 = xp**2 + yp**2

    # Sort the pixels by that radius, storing the pixel flux,
    # the pixel index, the radius of the pixel, and the flux
    # up to and including that pixel
    isort = np.argsort(r2, axis=None)
    pix = image.flat[isort] - fixmedian
    ivarsort = ivar.flat[isort]
    ivarsort[(ivarsort < 0.).nonzero()] = 0.
    varpix = (((ivarsort != 0.).astype(np.float32)) /
              (ivarsort + (ivarsort == 0.).astype(np.float32)))
    radius = np.sqrt(r2.flat[isort])
    ipix = np.arange(len(pix))
    flux = np.cumsum(pix)
    var = np.cumsum(varpix)
    if(radius[0] != 0.0):
        radius = np.append(np.zeros(1), radius)
        ipix = np.append(np.zeros(1), ipix)
        flux = np.append(np.zeros(1), flux)
        var = np.append(np.zeros(1), var)

    # Choose outer radii of apertures, and calculate flux and area within,
    # and also calculate an annular flux and area around each radius.
    # Inner bins are special cased; note that this method is not strictly
    # integrating the interpolated image, so may have artifacts in inner
    # regions.
    rbins= np.arange(int(max(radius)/1.25-1.))+1.
    rlo= rbins*0.8
    rlo[0:4]=np.array([0., 0., 2., 3])
    rhi= rbins*1.25
    rhi[0:4]=np.array([2., 2., 4., 5])
    interper= interpolate.interp1d(radius,flux) 
    fbins= interper(rbins)
    flobins= interper(rlo)
    fhibins= interper(rhi)
    interper= interpolate.interp1d(radius,var) 
    vbins= interper(rbins)
    interper= interpolate.interp1d(radius,ipix) 
    abins= interper(rbins)
    abins[0:4]= ba*np.pi*rbins[0:4]**2
    alobins= interper(rlo)
    alobins[0:4]= ba*np.pi*rlo[0:4]**2
    ahibins= interper(rhi)
    ahibins[0:4]= ba*np.pi*rhi[0:4]**2

    # Find surface brightness, enclosed flux, mean surface brightness, 
    # and Petrosian ratio
    meansb= fbins/abins
    sb= (fhibins-flobins)/(ahibins-alobins)

    # Put data into return dictionary
    rdict['rbins']= rbins
    rdict['fbins']= fbins
    rdict['abins']= abins
    rdict['meansb']= meansb
    rdict['sb']= sb
    rdict['rlobins']= rlo
    rdict['rhibins']= rhi
    rdict['alobins']= alobins
    rdict['ahibins']= ahibins
    rdict['flobins']= flobins
    rdict['fhibins']= fhibins
    rdict['vbins']= vbins

    # Get the Petrosian radius, if it is not given; look only out to first
    # time ratio crosses below threshold.  
    if(petrorad is None and forceflux is None):
        petroratio= sb/meansb
        ratiop0= petroratio0+np.zeros(len(petroratio))
        ibelow= (np.nonzero((petroratio < ratiop0) * (rbins >= minpetrorad)))[0]
        if(len(ibelow) > 0):
            ilowest= np.min(ibelow)
            icheck= np.array((ilowest, ilowest-1))
            interper=interpolate.interp1d(petroratio[icheck], rbins[icheck])
            petrorad= interper(petroratio0)
        else:
            return rdict

    if(forceflux is None):
        # Now get the Petrosian fluxes
        aprad= petrorad*npetro
        if(aprad>max(rbins)):
            aprad=max(rbins)
        interper= interpolate.interp1d(rbins, fbins) 
        petroflux=interper(aprad)
        interper= interpolate.interp1d(rbins, vbins) 
        petrovar=interper(aprad)
        petroivar= ((petrovar != 0.).astype(np.float32)/
                    (petrovar+(petrovar == 0.).astype(np.float32)))
    else:
        # If we have forced a given flux, and are calculating sizes
        # relative to that, we calculate the equivalent Petrosian radius
        petroflux=forceflux
        petroivar=0.
        imax=fbins.argmax()
        irad=np.arange(imax+1)
        if(petroflux>0. and petroflux < max(fbins[irad])):
            interper= interpolate.interp1d(fbins[irad], rbins[irad],
                                           bounds_error=False,
                                           fill_value=rbins[imax]) 
            aprad= interper(petroflux)
            petrorad=aprad/npetro
                
    # Given the Petrosian fluxes, get the 50% and 90% light radii
    if(petroflux>0. and petroflux < max(fbins)):
        irad= np.arange(np.nonzero(rbins<aprad)[0].max()+2)
        interper= interpolate.interp1d(fbins[irad], rbins[irad]) 
        try:
            petror50=interper(petroflux*0.5)
        except:
            petror50=-9999.
        try:
            petror90=interper(petroflux*0.9)
        except:
            petror90=-9999.
    else:
        petror50=-9999.
        petror90=-9999.

    rdict['flux']=petroflux
    rdict['ivar']=petroivar
    rdict['rad']=petrorad
    rdict['r50']=petror50
    rdict['r90']=petror90

    return rdict 
