"""
Galaxy model list utilities
"""

import os
import numpy as np
import astropy.io.fits as pyfits

def listrec(indx, flux, nx, ny, xcen, ycen, arcperpix):
    """Creates recarray associated with a list.
    
    Parameters
    ----------
    indx : index number in model
    flux : flux in model
    nx, ny : size of model image
    xcen, ycen : center for model image
    arcperpix : arcsec per pixel for each image

    Returns
    -------
    recarray with above quantities
    """

    dtype=[('indx', np.int32), 
           ('flux', np.float32), 
           ('nx', np.int32), 
           ('ny', np.int32), 
           ('xcen', np.float32), 
           ('ycen', np.float32),
           ('arcperpix', np.float32)
           ]
    data= np.empty(len(indx), dtype=dtype)
    data['indx']=indx
    data['flux']=flux
    data['nx']=nx
    data['ny']=ny
    data['xcen']=xcen
    data['ycen']=ycen
    data['arcperpix']=arcperpix
    return data
    
def listpath(take, modelname):
    """Returns the path to a model list
    
    Parameters
    ----------
    take : "take" to be implemented
    modelname : Name of model

    Returns:
      $FAKEPHOTOMETRY/[take]/model-list-[modelname].fits
    """

    pathname= os.path.join(os.getenv("FAKEPHOTOMETRY"), 
                           take, 'models', modelname)
    filename= os.path.join(pathname, 'model-list-'+modelname+'.fits')

    return filename
    
def parpath(take, modelname):
    """Returns the path to a model parameter list
    
    Parameters
    ----------
    take : "take" to be implemented
    modelname : Name of model

    Returns:
      $FAKEPHOTOMETRY/[take]/model-params-[modelname].fits
    """

    pathname= os.path.join(os.getenv("FAKEPHOTOMETRY"), 
                           take, 'models', modelname)
    filename= os.path.join(pathname, 'model-params-'+modelname+'.fits')

    return filename
