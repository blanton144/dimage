import numpy as np


def none(image, parameters=None):
    """
    Parameters
    ----------

    image : np.float32
        2-D array
    parameters : recarray
        array of parameters

    Returns
    -------

    new_image : np.float32
        2-D array, same as input
    new_ivar : np.float32
        2-D array filled with 1.s
    """

    ivar = np.ones(image.shape)
    return (image, ivar)
