"""
Reproject

Michael R. Blanton, 2015-02-04
"""

import ctypes 
import os
import numpy as np

def dresample(image, x, y, kernel='dampsinc', dampsinc=2.47,
              lanczos=2.):
    """Resamples a two-dimensional ndarray image in x, y 
    
    Parameters
    ----------
    image : [nx, ny] 2-D ndarray 
    x, y : [N] locations for samples
    kernel : Kernel to use in resampling (default 'dampsinc')
    dampsinc : Gaussian scale used for 'dampsinc' (default 2.47)
    lanczos : Lanczos scale parameter "a" (default 2)

    Returns
    -------
    samples : [N] samples

    Notes
    -----
    Calls dresample.c in libdimage.so
    
    """

    # Get library
    dimage_lib = ctypes.cdll.LoadLibrary(os.path.join(os.getenv("DIMAGE_DIR"), 
                                                      "lib", "libdimage.so"))

    # Convert image into sensible pointer
    if(image.dtype != np.float32):
        image_float32=image.astype(np.float32)
        image_ptr=image_float32.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    else:
        image_ptr=image.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    # Get pointer to library function
    if(kernel == 'dampsinc'): 
        dkernel =  dimage_lib.dkernel_dampsinc
        dimage_lib.dkernel_dampsinc_scale(ctypes.c_float(dampsinc))
        dkernel_size =  dimage_lib.dkernel_dampsinc_size()
    elif(kernel == 'puresinc'):
        dkernel =  dimage_lib.dkernel_puresinc
        dkernel_size =  dimage_lib.dkernel_puresinc_size()
    elif(kernel == 'bicubic'):
        dkernel =  dimage_lib.dkernel_bicubic
        dkernel_size =  dimage_lib.dkernel_bicubic_size()
    elif(kernel == 'linear'):
        dkernel =  dimage_lib.dkernel_linear
        dkernel_size =  dimage_lib.dkernel_linear_size()
    elif(kernel == 'lanczos'): 
        dkernel =  dimage_lib.dkernel_lanczos
        dimage_lib.dkernel_lanczos_scale(ctypes.c_float(lanczos))
        dkernel_size =  dimage_lib.dkernel_lanczos_size()
    else:
        print "No kernel: "+kernel

    nx=image.shape[0]
    ny=image.shape[1]
    nn=len(x)

    samples= np.zeros(nn, dtype=np.float32)
    samples_ptr=samples.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    if(x.dtype != np.float32):
        x_float32=x.astype(np.float32)
        x_ptr=x_float32.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    else:
        x_ptr=image.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    if(y.dtype != np.float32):
        y_float32=y.astype(np.float32)
        y_ptr=y_float32.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    else:
        y_ptr=image.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    dimage_lib.dresample(image_ptr, nx, ny, x_ptr, y_ptr, nn, 
                         samples_ptr, dkernel, 
                         ctypes.c_int(dkernel_size))

    return samples
