"""
Galaxy model list utilities
"""

import os
import numpy as np


def listrec(indx, flux, nx, ny, xcen, ycen, arcperpix):
    """Creates recarray associated with a list.

    Parameters
    ----------
    indx : int
        index number in model
    flux : float
        flux in model
    nx, ny : int
        size of model image (pixels)
    xcen, ycen : float
        center for model image (pixels)
    arcperpix : float
        arcsec per pixel for each image

    Returns
    -------
    data : ndarray
        ndarray with above quantities so named
    """

    dtype = [('indx', np.int32),
             ('flux', np.float32),
             ('nx', np.int32),
             ('ny', np.int32),
             ('xcen', np.float32),
             ('ycen', np.float32),
             ('arcperpix', np.float32)
             ]
    data = np.empty(len(indx), dtype=dtype)
    data['indx'] = indx
    data['flux'] = flux
    data['nx'] = nx
    data['ny'] = ny
    data['xcen'] = xcen
    data['ycen'] = ycen
    data['arcperpix'] = arcperpix
    return data


def listpath(take, modelname):
    """Returns the path to a model list

    Parameters
    ----------
    take : str
        "take" to be implemented
    modelname : str
        Name of model

    Returns
    -------
    path : str
        Path to model

    Notes
    -----
    Path is:
      $FAKEPHOTOMETRY/[take]/model-list-[modelname].fits
    """

    pathname = os.path.join(os.getenv("FAKEPHOTOMETRY"),
                            take, 'models', modelname)
    filename = os.path.join(pathname, 'model-list-' + modelname + '.fits')

    return filename


def parpath(take, modelname):
    """Returns the path to a model parameter list

    Parameters
    ----------
    take : str
        "take" to be implemented
    modelname : str
        Name of model

    Returns
    -------
    path : str
        path to parameter list

    Notes
    -----
    Path is of the form:
      $FAKEPHOTOMETRY/[take]/model-params-[modelname].fits
    """

    pathname = os.path.join(os.getenv("FAKEPHOTOMETRY"),
                            take, 'models', modelname)
    filename = os.path.join(pathname, 'model-params-' + modelname + '.fits')

    return filename
