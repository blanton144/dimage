"""
Render a .fits image and save as .png

Jason Angell
3-16-2015
"""

import matplotlib.pyplot as plt
from astropy.io import fits
import os
import numpy as np

def create_image(imfile, take, modelname, i):
    """ Renders and saves a .png file from a .fits image file

    Parameters
    ----------
    imfile : .fits image file input
    take : "take" for the current image
    modelname : model currently being worked on
    i : iteration of the current model / take
    (note - take, modelname, & i are needed only for the output path)

    Returns
    -------
    Location of saved .png output

    Notes
    -----
    Inputs from:
       $FAKEPHOTOMETRY/[take]/fake/[modelname]/fake-*.fits
    Outputs to:
       $FAKEPHOTOMETRY/[take]/fake/images/fake-*.png
    """
    
    outpath = os.path.join(os.getenv('FAKEPHOTOMETRY'), take, 'fake/images/fake-'+str(i)+'.png')
    hdulist = fits.open(imfile)
    im_data = hdulist[0].data

    base = 0
    # asinh stretch if $IMAGE_STRETCH isn't 0
    if(os.getenv('IMAGE_STRETCH') == None, 0):
        stretch_data = im_data
    else:
        base = float(os.getenv('IMAGE_STRETCH'))
        stretch_data = np.arcsinh(im_data/base)
    
    plt.imshow(stretch_data, cmap='gray')
    cbr = plt.colorbar()

    # change labels to stretched labels (if necessary)
    if(base != 0):
        labels = cbr.ax.get_yticklabels()
        for l in range(len(labels)):
            labels[l] = np.sinh(float(labels[l].get_text()))*base
            labels[l] = '{0:f}'.format(labels[l])
        cbr.ax.set_yticklabels(labels)
    
    plt.savefig(outpath)
    plt.clf()
    return outpath

