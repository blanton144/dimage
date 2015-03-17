"""
Render a .fits image and save as .png

Jason Angell
3-16-2015
"""

import matplotlib.pyplot as plt
from astropy.io import fits
import os

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
    plt.imshow(im_data, cmap='gray')
    plt.colorbar()
    
    plt.savefig(outpath)
    plt.clf()
    return outpath

