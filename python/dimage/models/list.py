"""
Galaxy model list utilities
"""

import os
import numpy as np
import astropy.io.fits as pyfits

def listrec(indx, flux, nx, ny, xcen, ycen):
    """Creates recarray associated with a list.
    
    Parameters
    ----------
    indx : index number in model
    flux : flux in model
    nx, ny : size of model image
    xcen, ycen : center for model image

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
           ]
    data= np.empty(len(indx), dtype=dtype)
    data['indx']=indx
    data['flux']=flux
    data['nx']=nx
    data['ny']=ny
    data['xcen']=xcen
    data['ycen']=ycen
    return data
    
def to_dir(curpath, next):
    """
    Checks to make sure a directory exists; then joins it to the working path
    
    Parameters
    ----------
    curpath : current working path
    next : next directory to be added 
    
    Returns:
      curpath/next
    """
    
    if(os.path.exists(os.path.join(workd, nextd))):
        return os.path.join(workd, nextd)
    else:
        r_path = os.path.join(workd, nextd)
        os.mkdir(r_path)
        return r_path

def to_file(curpath, name):
    """
    Checks to make sure a file exists; then joins it to the working path
    
    Parameters
    ----------
    curpath : current working path
    name : name of file to be added

    returns curpath/name
    """

    if(os.path.exists(os.path.join(curpath, name))):
        return os.path.join(curpath, name)
    else:
        r_path = os.path.join(curpath, name)
        os.mkdir(r_path)
        return r_path

def listpath(take, modelname):
    """Returns the path to a model list
    
    Parameters
    ----------
    take : "take" to be implemented
    modelname : Name of model

    Returns:
      $FAKEPHOTOMETRY/[take]/model-list-[modelname].fits
    """

    pathname = to_dir(os.getenv("FAKEPHOTOMETRY"), take)
    pathname = to_dir(pathname, 'models')
    pathname = to_dir(pathname, modelname)
    
    filename= to_file(pathname, 'model-list-'+modelname+'.fits')

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
    pathname = to_dir(os.getenv("FAKEPHOTOMETRY"), take)
    pathname = to_dir(pathname, 'models')
    pathname = to_dir(pathname, take)
    
    filename= to_file(pathname, 'model-params-'+modelname+'.fits')

    return filename
