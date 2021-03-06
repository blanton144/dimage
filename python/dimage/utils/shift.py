import ctypes
import os
import numpy as np


def shift(image, dx, dy, kernel='dampsinc', dampsinc=2.47,
          lanczos=2.):
    """Shifts image by non-integer amount.
    Interpolates using one of a set of specified kernels.

    Parameters
    ----------
    image : numpy.float32 array
        2-D image to be shifted; is altered on return
    dx, dy : numpy.float32
        amount to shift images (pixels)
    kernel : str
        kernel to use in resampling (default 'dampsinc')
    dampsinc : float
        Gaussian scale used for 'dampsinc' (default 2.47)
    lanczos : float
        Lanczos scale parameter "a" for 'lanczos' (default 2)

    Notes
    -----
    Available kernels: 'dampsinc', 'puresinc', 'bicubic', 'linear',
    'lanczos'. Calls dshift.c in libdimage.so

    """

    # Get library
    dimage_lib = ctypes.cdll.LoadLibrary(os.path.join(os.getenv("DIMAGE_DIR"),
                                                      "lib", "libdimage.so"))

    # Convert image into sensible pointer
    if(image.dtype != np.float32):
        image_float32 = image.astype(np.float32)
        image_ptr = image_float32.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    else:
        image_ptr = image.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    # Get pointer to library function
    if(kernel == 'dampsinc'):
        dkernel = dimage_lib.dkernel_dampsinc
        dimage_lib.dkernel_dampsinc_scale(ctypes.c_float(dampsinc))
        dkernel_size = dimage_lib.dkernel_dampsinc_size()
    elif(kernel == 'puresinc'):
        dkernel = dimage_lib.dkernel_puresinc
        dkernel_size = dimage_lib.dkernel_puresinc_size()
    elif(kernel == 'bicubic'):
        dkernel = dimage_lib.dkernel_bicubic
        dkernel_size = dimage_lib.dkernel_bicubic_size()
    elif(kernel == 'linear'):
        dkernel = dimage_lib.dkernel_linear
        dkernel_size = dimage_lib.dkernel_linear_size()
    elif(kernel == 'lanczos'):
        dkernel = dimage_lib.dkernel_lanczos
        dimage_lib.dkernel_lanczos_scale(ctypes.c_float(lanczos))
        dkernel_size = dimage_lib.dkernel_lanczos_size()
    else:
        print("No kernel: " + kernel)

    nx = image.shape[0]
    ny = image.shape[1]

    dimage_lib.dshift(image_ptr, nx, ny, ctypes.c_float(dy),
                      ctypes.c_float(dx), dkernel, ctypes.c_int(dkernel_size))

    return
