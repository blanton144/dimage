import ctypes
import os
import numpy as np


def find(image):
    """Find non-zero continguous objects

    Parameters
    ----------
    image : np.float32
        2-D ndarray

    Returns
    -------
    object : np.float32
        2-D ndarray

    Notes
    -----
    Calls dfind.c in libdimage.so

    """

    # Get simplexy C function
    dimage_lib = ctypes.cdll.LoadLibrary(os.path.join(os.getenv("DIMAGE_DIR"),
                                                      "lib", "libdimage.so"))
    dfind_function = dimage_lib.dfind

    # Create image pointer
    if(image.dtype != np.float32):
        image_float32 = image.astype(np.float32)
        image_ptr = image_float32.ctypes.data_as(ctypes.POINTER(ctypes.c_float))
    else:
        image_ptr = image.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    nx = image.shape[0]
    ny = image.shape[1]

    object = np.zeros((nx, ny), dtype=np.int32)
    object_ptr = object.ctypes.data_as(ctypes.POINTER(ctypes.c_float))

    dfind_function(image_ptr, nx, ny, object_ptr)

    return object
