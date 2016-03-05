"""
Galaxy model list utilities
"""

import os
import fitsio
import dimage.path
import numpy as np
import pydl.pydlutils.yanny.yanny as Yanny
import dimage.utils.wcssimple as wcssimple

dpath = dimage.path.Path()


class Model(object):
    """
    Class holding a generic list of models for take images
    """
    def __init__(self, take=None, modelname=None, read=True):
        self.take = take
        self.modelname = modelname
        self.filename = dpath.full('model-params', take=self.take,
                                   model=self.modelname)
        self.take_params = Yanny(dpath.full('take-params', take=take))
        imodel = np.nonzero(np.array(self.take_params['MODEL']['modelname']) ==
                            modelname)[0][0]
        self.nmodel = self.take_params['MODEL']['nmodel'][imodel]
        self.params = None
        if(read):
            self.params = fitsio.read(self.filename)

    def header(self, indx=None):
        arcsec_per_pixel = np.float32(self.take_params['arcsec_per_pixel'])
        xsize = (1. / 3600) * self.params['nx'][indx] * arcsec_per_pixel
        ysize = (1. / 3600) * self.params['ny'][indx] * arcsec_per_pixel
        wcsheader = wcssimple(180., 0., (xsize, ysize), arcsec_per_pixel)[0]
        header = wcsheader.to_header()
        return header

    def basic(self):
        """Creates basic record array associated with the model list.

        Returns
        -------
        data : ndarray
            ndarray with basic quantities

        Notes
        -----
        Basic quantities are: indx, flux, nx, ny, xcen, ycen
        """

        dtype = [('indx', np.int32),
                 ('flux', np.float32),
                 ('nx', np.int32),
                 ('ny', np.int32),
                 ('xcen', np.float32),
                 ('ycen', np.float32),
                 ]
        basic = np.empty(len(self.params['indx']), dtype=dtype)
        basic['indx'] = self.params['indx']
        basic['flux'] = self.params['flux']
        basic['nx'] = self.params['nx']
        basic['ny'] = self.params['ny']
        basic['xcen'] = self.params['xcen']
        basic['ycen'] = self.params['ycen']
        return basic

    def write(self, clobber=True):
        dirname = os.path.dirname(self.filename)
        if(os.path.isdir(dirname) is False):
            os.makedirs(dirname)
        fitsio.write(self.filename, self.params, clobber=clobber)
