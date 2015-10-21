"""
Create fake Sersic galaxy image. 

Michael R. Blanton, 2014-12-07
"""

import ctypes
import os
import numpy as np


def sersic(nx, ny, xcen=None, ycen=None, n=1., r50=3., ba=1., phi=0.,
           simple=False):
    """Create fake Sersic galaxy image.

    Parameters
    ----------
    nx : int
        size in X of output array
    ny : int
        size in Y of output array
    xcen : float
        X center (default to nx/2.)
    ycen : float
        Y center (default to ny/2.)
    n : float
        Sersic index (default 1.)
    r50 : float
        Sersic half-light radius (default 3.)
    ba : float
        Sersic minor-to-major axis ratio (default 1.)
    phi : float
        Sersic position angle (default 0.)
    simple : bool
        if True, just evaluate, don't integrate at center (default False)

    Returns
    -------
    image : np.float32
        2-D ndarray (nx,ny) with fake image

    """

    dimage_lib = ctypes.cdll.LoadLibrary(os.path.join(os.getenv("DIMAGE_DIR"),
                                                      "lib", "libdimage.so"))
    dfake_func = dimage_lib.dfake

    image = np.zeros((nx, ny), dtype=np.float32)
    image_ptr = image.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    if(simple):
        isimple = 1
    else:
        isimple = 0

    if(xcen is None):
        xcen = float(nx) / 2.
    if(ycen is None):
        ycen = float(ny) / 2.

    dfake_func(image_ptr, ctypes.c_int(nx), ctypes.c_int(ny),
               ctypes.c_float(xcen), ctypes.c_float(ycen),
               ctypes.c_float(n), ctypes.c_float(r50),
               ctypes.c_float(ba), ctypes.c_float(phi),
               ctypes.c_int(isimple))

    return image
