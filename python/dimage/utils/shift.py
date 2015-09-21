"""
Shift an image in x and y

Michael R. Blanton, 2015-02-04
"""

import ctypes 
import os
import numpy as np

def shift(image, dx, dy, kernel='dampsinc', dampsinc=2.47,
           lanczos=2.):
    """returns (arg1 / arg2) + arg3

        This is a longer explanation, which may include math with latex syntax
        :math:`\\alpha`.
        Then, you need to provide optional subsection in this order (just to be
        consistent and have a uniform documentation. Nothing prevent you to
        switch the order):

          - parameters using ``:param <name>: <description>``
          - type of the parameters ``:type <name>: <description>``
          - returns using ``:returns: <description>``
          - examples (doctest)
          - seealso using ``.. seealso:: text``
          - notes using ``.. note:: text``
          - warning using ``.. warning:: text``
          - todo ``.. todo:: text``

        **Advantages**:
         - Uses sphinx markups, which will certainly be improved in future
           version
         - Nice HTML output with the See Also, Note, Warnings directives


        **Drawbacks**:
         - Just looking at the docstring, the parameter, type and  return
           sections do not appear nicely

        :param image: the first value
        :param arg2: the first value
        :param arg3: the first value
        :type arg1: int, float,...
        :type arg2: int, float,...
        :type arg3: int, float,...
        :returns: arg1/arg2 +arg3
        :rtype: int, float

        :Example:

        >>> import template
        >>> a = template.MainClass1()
        >>> a.function1(1,1,1)
        2

        .. note:: can be useful to emphasize
            important feature
        .. seealso:: :class:`MainClass2`
        .. warning:: arg2 must be non-zero.
        .. todo:: check that arg2 is non zero.

    Shifts a two-dimensional ndarray image in x, y 
    
    Parameters
    ----------
    image : 2-D ndarray 
    dx, dy : amount to shift images
    kernel : Kernel to use in resampling (default 'dampsinc')
    dampsinc : Gaussian scale used for 'dampsinc' (default 2.47)
    lanczos : Lanczos scale parameter "a" (default 2)

    Returns
    -------
    newimage : shifted image

    Notes
    -----
    Calls dshift.c in libdimage.so
    
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

    dimage_lib.dshift(image_ptr, nx, ny, ctypes.c_float(dy), 
                      ctypes.c_float(dx), dkernel, ctypes.c_int(dkernel_size))

    return 
