import numpy as np


def constant(image, parameters=None):
    """
    Parameters
    ----------

    image : np.float32
        2-D array
    parameters : recarray
        array of parameters (must include 'background')

    Returns
    -------

    new_image : np.float32
        2-D array, same shape as input, with background added
    """

    image = image + np.float32(parameters['background'])

    return image
