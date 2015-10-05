#!/usr/bin/env python

# No condition - returns data exactly as given
# Primarily here to make sure the rest of the pipeline will work for more
# complicated conditions
#
# JPA 2015-04-27


def nocond(im_data):
    """
    Applies no observing conditions, just returns image data unchanged.

    Parameters
    ----------

    image : np.float32
        2-D array

    Returns
    -------

    new_image : np.float32
        2-D array, same shape as input
    """

    return im_data
