"""
Code to combine unWISE images onto a square patch.
Uses dimage.combine.combine.

Michael R. Blanton, 2015-03-07
"""

import os
import astropy.io.fits as pyfits
import dimage.combine
import astropy.coordinates as coordinates
import math


def combine_wise(ra, dec, size, band, 
                  kernel='lanczos', dampsinc=2.47,
                  lanczos=2., edge=10, pixscale=2.75,
                  unmasked=False):
    """Combine WISE images onto a desired footprint

    Parameters
    ----------
    ra, dec : fp.float64
        center of image (J2000 deg)
    size : float
        size of square image (deg)
    band : str
        band name ('W1', 'W2', 'W3', 'W4')
    edge : int
        pixel width of apodized edge to use (default 10)
    kernel, dampsinc, lanczos : parameters for dresample
    pixscale : float
        output pixel scale in arcsec/pixel (default 2.75)
    unmasked : bool
        if True, use unmasked coadds (default False)

    Returns
    -------
    (image, ivar, wcs) : (np.float32, np.float32, WCS)
       [nx, ny] image
       [nx, ny] image inverse variance
       WCS object

    """

    # Read in list of WISE tiles
    tilelist_file = os.path.join(os.getenv('UNWISE_DATA'), 'tiles.fits')
    alltiles = pyfits.open(tilelist_file)[1].data

    # Find those related to this location 
    wise_size = 2048. * 2.75 / 3600.
    radius = (wise_size + size) * math.sqrt(2.) / 2.
    center_c = coordinates.SkyCoord([ra], [dec], unit="deg")
    tile_c = coordinates.SkyCoord(alltiles['RA'], alltiles['Dec'], unit="deg")
    (indx, sep2d, sep3d) = coordinates.match_coordinates_sky(tile_c, center_c)

    # define postfix (m for masked, u for unmasked)
    postfix = "m"
    if(unmasked):
        postfix = "u"

    # Construct file names in list
    image_files = []
    ivar_files = []
    indx = indx.reshape(indx.size)
    for (i, sep2d_curr) in zip(range(len(tile_c)), sep2d):
        if(sep2d_curr.deg < radius):
            tile = alltiles['COADD_ID'][i]
            topdir = tile[0:3]
            botdir = tile
            tiledir = os.path.join(os.getenv('UNWISE_DATA'), topdir, botdir)
            tmp_file = 'unwise-' + tile + '-' + band + '-' + 'img-' + postfix + '.fits'
            tmp_file = os.path.join(tiledir, tmp_file)
            image_files.append(tmp_file)
            tmp_file = 'unwise-' + tile + '-' + band + '-' + 'invvar-' + postfix + '.fits.gz'
            tmp_file = os.path.join(tiledir, tmp_file)
            ivar_files.append(tmp_file)

    # Make combination
    (image, ivar, wcs) = dimage.combine.combine(ra, dec, size, pixscale,
                                                image_files,
                                                ivar_files=ivar_files,
                                                kernel=kernel,
                                                dampsinc=dampsinc, edge=edge)

    return (image, ivar, wcs)
