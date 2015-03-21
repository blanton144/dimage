"""
Code to combine unWISE images onto a square patch.
Uses dcombine.

Michael R. Blanton, 2015-03-07
"""

import os
import numpy as np
import astropy.io.fits as pyfits
import dimage
import astropy.coordinates as coordinates
import math

def dcombine_wise(ra, dec, size, band, 
                  kernel='lanczos', dampsinc=2.47,
                  lanczos=2., edge=10):
    """Combine WISE images onto a desired footprint
    
    Parameters
    ----------
    ra, dec : center of image (J2000 deg)
    size : size of square image (deg)
    band : band name ('W1', 'W2', 'W3', 'W4')
    edge : pixel width of apodized edge to use (default 10)
    kernel, dampsinc, lanczos : parameters for dresample

    Returns
    -------
    (image, ivar, wcs) : 
       [nx, ny] image
       [nx, ny] image inverse variance
       WCS object

    """

    # Read in list of WISE tiles
    tilelist_file= os.path.join(os.getenv('UNWISE_DATA'), 'tiles.fits')
    alltiles= pyfits.open(tilelist_file)[1].data

    # Find those related to this location 
    wise_size= 2048.*2.75/3600.
    radius= (wise_size+size)*math.sqrt(2.)/2.
    center_c = coordinates.SkyCoord(ra, dec, unit="deg")
    tile_c = coordinates.SkyCoord(alltiles['RA'], alltiles['Dec'], unit="deg")
    (indx, sep2d, sep3d)= coordinates.match_coordinates_sky(center_c, tile_c)

    # Construct file names in list
    image_files=[]
    ivar_files=[]
    indx= indx.reshape(indx.size)
    for i in indx:
        tile=alltiles['COADD_ID'][i]
        topdir=tile[0:3]
        botdir=tile
        tiledir= os.path.join(os.getenv('UNWISE_DATA'), topdir, botdir)
        tmp_file= 'unwise-'+tile+'-'+band+'-'+'img-m.fits'
        tmp_file=os.path.join(tiledir, tmp_file)
        image_files.append(tmp_file)
        tmp_file= 'unwise-'+tile+'-'+band+'-'+'invvar-m.fits.gz'
        tmp_file=os.path.join(tiledir, tmp_file)
        ivar_files.append(tmp_file)

    # Make combination
    pixscale=2.75
    (image, ivar, wcs)= dimage.dcombine(ra, dec, size, pixscale, image_files,
                                        ivar_files=ivar_files,kernel=kernel,
                                        dampsinc=dampsinc, edge=edge)

    return (image, ivar, wcs)
