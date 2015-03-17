"""
Code to combine a desired set of images onto a common footprint. 
Can use various resampling kernels; see documentation for dresample. 

Notes and to-do:
----------------

- Does not adjust for pixel area changes; keeps image in whatever units
  it was input in.

- Uses simple TAN projection and square image; doesn't yet take arbitrary
  WCS inputs.

- Will fail on images which span > 180 deg in RA, due to simplistic 
  handling of 0/360 boundary

Michael R. Blanton, 2015-02-04
"""

import os
import numpy as np
import astropy.io.fits as pyfits
import astropy.wcs as wcs
import dimage

def dcombine_apodize(nx, ny, edge=10):
    """Create apodized weight image

    Parameters
    ----------
    nx, ny : dimensions of image
    edge : pixel width of apodized edge (default 10)

    Returns
    -------
    weight : [nx, ny] weighted image
    
    Notes
    -----
    Uses a cos() function transition from zero to unity in 
    each dimension along each edge.
    """
    
    edgeweight= 0.5*(1.-np.cos(np.arange(edge)*np.pi/np.float32(edge)))
    weight= np.ones((nx,ny), dtype=np.float32)
    weight[:, 0:edge]= (weight[:, 0:edge]*
                        np.outer(np.ones(nx, dtype=np.float32), edgeweight))
    weight[:, ny-edge:ny]= (weight[:, ny-edge:ny]*
                            np.outer(np.ones(nx, dtype=np.float32), edgeweight[::-1]))
    weight[0:edge, :]= (weight[0:edge, :]*
                        np.outer(edgeweight, np.ones(ny, dtype=np.float32)))
    weight[nx-edge:nx, :]= (weight[nx-edge:nx, :]*
                            np.outer(edgeweight[::-1], np.ones(ny, dtype=np.float32)))
    return weight

def dcombine(ra, dec, size, pixscale, tiles, 
             kernel='lanczos', dampsinc=2.47,
             lanczos=2., edge=10):
    """Combine a list of images onto a desired footprint
    
    Parameters
    ----------
    ra, dec : center of image (J2000 deg)
    size : size of square image (deg)
    pixelscale : pixel scale (arcsec)
    tiles : [N] list of file names
    edge : pixel width of apodized edge to use (default 10)
    kernel, dampsinc, lanczos : parameters for dresample

    Returns
    -------
    (image, wcs) : 
       [nx, ny] image
       WCS object

    Notes
    -----
    Uses a weighted combination with apodized edges of images to 
      ensure smooth transitions. 
    Calls dwcsproject for projection, which calls dresample.

    """
    
    # Create simple WCS
    (target_wcs, nx, ny)= dimage.dwcssimple(ra, dec, size, pixscale)

    # Create grid of RA/Dec values for each pixel
    (ragrid, decgrid)= dimage.dwcsgrid(target_wcs, nx, ny)

    image= np.zeros(nx*ny, dtype=np.float32)
    weight= np.zeros(nx*ny, dtype=np.float32)
    for tile in tiles:
        # Get image from file
        hdus=pyfits.open(tile)
        tile_image= hdus[0].data 
        tile_wcs= wcs.WCS(hdus[0].header)
        
        # Create apodized weight
        tile_weight= dimage.dcombine_apodize(tile_image.shape[0],
                                             tile_image.shape[1],edge=edge)

        # Interpolate actual image image
        (tmp_image, tmp_weight, inbox)= dimage.dwcsproject(
            tile_image, tile_weight, tile_wcs, ragrid, decgrid,
            kernel=kernel, dampsinc=dampsinc, lanczos=lanczos)

        # Add weighted image and weights to sum
        if(tmp_image is not None):
            image[inbox]= (image[inbox]+ tmp_image*tmp_weight)
            weight[inbox]= (weight[inbox]+tmp_weight)

    # For all pixels with some weight in them, evaluate weighted
    # average (image/weight)
    nz= np.nonzero(weight)
    image[nz]= image[nz]/weight[nz]

    return (image.reshape(nx,ny), target_wcs)   
