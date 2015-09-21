"""
Sersic 1D model utilities
"""

import os
import sys
import numpy as np
import astropy.io.fits as pyfits
import random
import scipy
import dimage.fake.models 
import dimage.utils.path

apath= dimage.utils.path()

def rlimit(n, frac=0.99):
    bn= scipy.special.gammaincinv(2.*n, 0.5)
    return (scipy.special.gammaincinv(2.*n, frac)/bn)**n

def readlist(take, modelname):
    """Reads in Sersic 1D model list
    
    Parameters
    ----------
    take : "take" to be implemented
    modelname : Name of model

    Returns
    -------
    recarray containing list

    Notes
    -----
    Inputs from:  
       $FAKEPHOTOMETRY/[take]/models/[modelname]/model-list-[modelname].fits
    """

    infile= apath.full('model-list', take=take, model=modelname)
    fp= pyfits.open(infile)
    return fp[1].data

def readpar(take, modelname):
    """Reads in Sersic 1D model parameter list
    
    Parameters
    ----------
    take : "take" to be implemented
    modelname : Name of model

    Returns
    -------
    recarray containing list

    Notes
    -----
    Inputs from:  
       $FAKEPHOTOMETRY/[take]/models/[modelname]/model-list-[modelname].fits
    """

    infile= dimage.fake.models.parpath(take, modelname)
    fp= pyfits.open(infile)
    return fp[1].data

def writelist(take, modelname, rflux, r50, n, phi, ba, arcperpix):
    """Writes out Sersic 1D model list
    
    Parameters
    ----------
    take : "take" to be implemented
    modelname : Name of model
    rflux : ndarray of fluxes
    r50 : ndarray of half-light radii
    n : ndarray of Sersic indices
    phi : ndarray of position angles
    ba : ndarray of minor-to-major (b/a) axis ratios
    arcperpix: ndarray of arcsec per pixel (default is 0.2)

    Notes
    -----
    Outputs into dir:  
       $FAKEPHOTOMETRY/[take]/models/[modelname]
    the two files:
       model-list-[modelname].fits
       model-params-[modelname].fits
    Creates the directory if not already present (not including $FAKEPHOTOMETRY)
    """
    
    if(os.getenv('FAKEPHOTOMETRY') == None):
        print('Must set $FAKEPHOTOMETRY to a valid directory')
        sys.exit(1)
    if os.path.exists(os.path.join(
            os.getenv('FAKEPHOTOMETRY'), take, 'models', modelname)) == False:
        os.makedirs(os.path.join(os.getenv('FAKEPHOTOMETRY'), take, 'models'))
        f = open(os.path.join(
            os.getenv('FAKEPHOTOMETRY'), take, 'models', modelname))
        f.close()

    outfile= dimage.fake.models.listpath(take, modelname)
    parfile= dimage.fake.models.parpath(take, modelname)
    
    # Set index number
    indx= np.arange(len(rflux), dtype=np.int32)
    
    # Determine sizes
    size= np.int32(2*np.int32(rlimit(n)*r50)+1)
    ilow= np.where(size < 151)
    size[ilow]=151
    
    # Jitter centers
    xcen= np.zeros(len(rflux), dtype=np.float32)
    ycen= np.zeros(len(rflux), dtype=np.float32)
    for i in range(len(rflux)):
       	xcen[i]= np.float32(size[i]/2)-0.5+random.uniform(0., 1.)
       	ycen[i]= np.float32(size[i]/2)-0.5+random.uniform(0., 1.)
        
    # put into recarray
    data= listrec(indx, rflux, size, size, xcen, ycen, arcperpix)

    hdu0= pyfits.PrimaryHDU()
    hdu1= pyfits.BinTableHDU(data=data, name='Model list')
    hdus= pyfits.HDUList(hdus=[hdu0,hdu1])
    hdus.writeto(outfile, clobber=True)
    
    dtype=[('indx', np.int32), 
           ('nx', np.int32), 
           ('ny', np.int32), 
           ('xcen', np.float32), 
           ('ycen', np.float32), 
           ('flux', np.float32), 
           ('r50', np.float32), 
           ('n', np.float32), 
           ('phi', np.float32), 
           ('ba', np.float32),
           ('arcperpix', np.float32)
           ]
    data= np.empty(len(indx), dtype=dtype)
    data['indx']=indx
    data['nx']=size
    data['ny']=size
    data['xcen']=xcen
    data['ycen']=ycen
    data['flux']=rflux
    data['r50']=r50
    data['n']=n
    data['phi']=phi
    data['ba']=ba
    data['arcperpix']=arcperpix
    
    hdu0= pyfits.PrimaryHDU()
    hdu1= pyfits.BinTableHDU(data=data, name='Model parameters list')
    hdus= pyfits.HDUList(hdus=[hdu0,hdu1])
    hdus.writeto(parfile, clobber=True)
    
