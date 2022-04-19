import ctypes
import os
import numpy as np


def refine(image=None, x=None, y=None, psf_sigma=2., cutout=19):
    """Refines positions of stars in an image.

    Parameters
    ----------

    image : np.float32
        2-D ndarray

    x : np.float32
        1-D ndarray of rough x positions

    y : np.float32
        1-D ndarray of rough y positions

    psf_sigma : float
        sigma of Gaussian PSF to assume (default 2 pixels)

    cutout : int
        size of cutout used, should be odd (default 19)

    Returns
    -------

    xr : ndarray of np.float32
        refined x positions

    yr : ndarray of np.float32
        refined y positions

    Notes
    -----
    Calls drefine.c in libdimage.so
"""

    # Get simplexy C function
    dimage_lib = ctypes.cdll.LoadLibrary(os.path.join(os.getenv("DIMAGE_DIR"),
                                                      "lib", "libdimage.so"))
    drefine_function = dimage_lib.drefine

    # Create image pointer
    if(image.dtype != np.float32):
        image_float32 = image.astype(np.float32)
        image_ptr = image_float32.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    else:
        image_ptr = image.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    nx = image.shape[0]
    ny = image.shape[1]
    psf_sigma_ptr = ctypes.c_float(psf_sigma)

    ncen = len(x)
    ncen_ptr = ctypes.c_int(ncen)
    cutout_ptr = ctypes.c_int(cutout)
    xrough = np.float32(x)
    xrough_ptr = xrough.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    yrough = np.float32(y)
    yrough_ptr = yrough.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    xrefined = np.zeros(ncen, dtype=np.float32)
    xrefined_ptr = xrefined.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    yrefined = np.zeros(ncen, dtype=np.float32)
    yrefined_ptr = yrefined.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    drefine_function(image_ptr, nx, ny, 
                     xrough_ptr, yrough_ptr, xrefined_ptr, yrefined_ptr,
                     ncen_ptr, cutout_ptr, psf_sigma_ptr)

    return (xrefined, yrefined)
