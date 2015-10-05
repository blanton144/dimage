import ctypes
import os
import numpy as np


def simplexy(image, psf_sigma=1., plim=8., dlim=1., saddle=3., maxper=1000,
             maxnpeaks=100000):
    """Determines positions of stars in an image.

    Parameters
    ----------
    image : np.float32
        2-D ndarray
    psf_sigma : float
        sigma of Gaussian PSF to assume (default 1 pixel)
    plim : float
        significance to select objects on (default 8)
    dlim : float
        tolerance for closeness of pairs of objects (default 1 pixel)
    saddle : float
        tolerance for depth of saddle point to separate sources
        (default 3 sigma)
    maxper : int
        maximum number of children per parent (default 1000)
    maxnpeaks : int
        maximum number of stars to find total (default 100000)

    Returns
    -------
    (x, y, flux) : (np.float32, np.float32, np.float32)
         ndarrays with pixel positions and peak pixel values of stars

    Notes
    -----
    Calls simplexy.c in libdimage.so

    """

    # Get simplexy C function
    dimage_lib = ctypes.cdll.LoadLibrary(os.path.join(os.getenv("DIMAGE_DIR"),
                                                      "lib", "libdimage.so"))
    simplexy_function = dimage_lib.simplexy

    # Create image pointer
    if(image.dtype != np.float32):
        image_float32 = image.astype(np.float32)
        image_ptr = image_float32.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    else:
        image_ptr = image.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    nx = image.shape[0]
    ny = image.shape[1]
    psf_sigma_ptr = ctypes.c_float(psf_sigma)
    plim_ptr = ctypes.c_float(plim)
    dlim_ptr = ctypes.c_float(dlim)
    saddle_ptr = ctypes.c_float(saddle)
    maxper_ptr = ctypes.c_int(maxper)
    maxnpeaks_ptr = ctypes.c_int(maxnpeaks)

    x = np.zeros(maxnpeaks, dtype=np.float32)
    x_ptr = x.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    y = np.zeros(maxnpeaks, dtype=np.float32)
    y_ptr = y.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    flux = np.zeros(maxnpeaks, dtype=np.float32)
    flux_ptr = flux.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    sigma = ctypes.c_float(0.)
    npeaks = ctypes.c_int(0)

    simplexy_function(image_ptr, nx, ny, psf_sigma_ptr, plim_ptr,
                      dlim_ptr, saddle_ptr, maxper_ptr, maxnpeaks_ptr,
                      ctypes.byref(sigma), x_ptr, y_ptr, flux_ptr,
                      ctypes.byref(npeaks))

    npeaks = npeaks.value
    x = x[0:npeaks]
    y = y[0:npeaks]
    flux = flux[0:npeaks]

    return (x, y, flux)
