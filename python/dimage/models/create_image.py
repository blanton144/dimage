"""
Render a .fits image and save as .png

Jason Angell
3-16-2015
"""

import matplotlib.pyplot as plt
from astropy.io import fits
import os
import numpy as np

def create_image(imfile, take, modelname, i, base):
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
    Inputs from:
       $FAKEPHOTOMETRY/[take]/fake/[modelname]/fake-*.fits
    Outputs to:
       $FAKEPHOTOMETRY/[take]/fake/images/fake-*.png
    """

    # outpath should go to output directory, in <model>/png/image-<i>.png
    outpath = os.path.join(os.getenv('FAKEPHOTOMETRY'), take, 'models', modelname, 'png', 'image-'+str(i)+'.png')
    hdulist = fits.open(imfile)
    im_data = hdulist[0].data

    # change labels to stretched labels (if necessary)
    if(base != 0):
        stretch_data = np.arcsinh(im_data/base)
        plt.imshow(stretch_data, cmap='gray')
        cbr = plt.colorbar()
        labels = cbr.ax.get_yticklabels()
        for l in range(len(labels)):
            labels[l] = np.sinh(float(labels[l].get_text()))*base
            labels[l] = '{0:f}'.format(labels[l])
        cbr.ax.set_yticklabels(labels)
    else:
        plt.imshow(im_data, cmap='gray')
        cbr = plt.colorbar()
    
    plt.savefig(outpath)
    plt.clf()
    return outpath
