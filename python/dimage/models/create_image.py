"""
Render a .fits image and save as .png

Jason Angell
3-16-2015
"""

import matplotlib.pyplot as plt
from astropy.io import fits
import os
import numpy as np

def create_image(imfile, outfile, base=0):
    """ Renders and saves a .png file from a .fits image file

    Parameters
    ----------
    imfile : .fits image file input
    take : "take" for the current image
    modelname : model currently being worked on
    i : iteration of the current model / take
    (note - take, modelname, & i are needed only for the output path)
    base : arcsinh stretching base. if 0, no stretching

    Returns
    -------
    Location of saved .png output

    Notes
    -----
    Inputs from imfile
    Outputs to outfile
    """

    hdulist = fits.open(imfile)
    im_data = hdulist[0].data

    if(base != 0):
        stretch_data = np.arcsinh(im_data/base)
        plt.imshow(stretch_data, cmap='gray')
        cbr = plt.colorbar()
        # labels should be stretched as well
        labels = cbr.ax.get_yticklabels()
        for l in range(len(labels)):
            labels[l] = np.sinh(float(labels[l].get_text()))*base
            labels[l] = '{0:f}'.format(labels[l])
        cbr.ax.set_yticklabels(labels)
    else:
        # no stretching; default
        plt.imshow(im_data, cmap='gray')
        cbr = plt.colorbar()
    
    plt.savefig(outfile)
    plt.clf()
    return outfile
