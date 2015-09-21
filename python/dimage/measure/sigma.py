"""
Estimate standard deviation in image, through simple checking of
pairwise differences on small scales.

Michael R. Blanton, 2014-12-07
"""

import ctypes 
import os
import numpy as np

def dsigma(image, sp=10):
    """Calculates standard deviation in image by checking pixel pairs
    
    Parameters
    ----------
    image : 2-D ndarray 
    sp : spacing between pixel pairs (default 10)

    Returns
    -------
    sigma : standard deviation

    Notes
    -----
    Calls dsigma.c in libdimage.so
    
    """

    dimage_lib = ctypes.cdll.LoadLibrary(os.path.join(os.getenv("DIMAGE_DIR"), 
                                                      "lib", "libdimage.so"))
    dsigma =  dimage_lib.dsigma
    if(image.dtype != np.float32):
        image_float32=image.astype(np.float32)
        image_ptr=image_float32.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    else:
        image_ptr=image.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    sigma=ctypes.c_float(0.)
    nx=image.shape[0]
    ny=image.shape[1]
    dsigma(image_ptr, nx, ny, 10, ctypes.byref(sigma))

    return sigma.value 
