"""
Sersic 1D model utilities
"""

import numpy as np
import random
import scipy
import dimage.fake.utils.sersic as sersic
from dimage.fake.models.model import Model


def rlimit(n, frac=0.99):
    bn = scipy.special.gammaincinv(2. * n, 0.5)
    return (scipy.special.gammaincinv(2. * n, frac) / bn)**n


class Sersic1(Model):
    def __init__(self, take=None, modelname=None, read=False):
        super(Sersic1, self).__init__(take=take, modelname=modelname,
                                      read=read)

    def image(self, indx=None):
        simage = sersic(nx=self.params['nx'][indx],
                        ny=self.params['ny'][indx],
                        xcen=self.params['xcen'][indx],
                        ycen=self.params['ycen'][indx],
                        n=self.params['n'][indx],
                        r50=self.params['r50'][indx],
                        ba=self.params['ba'][indx],
                        phi=self.params['phi'][indx],
                        simple=False)
        return simage

    def set_params(self, flux=None, r50=None, n=None,
                   phi=None, ba=None):
        """Inserts parameters into Sersic1.params

        Parameters
        ----------
        flux : np.float32
            ndarray of fluxes
        r50 : np.float32
            ndarray of half-light radii
        n : np.float32
            ndarray of Sersic indices
        phi : np.float32
            ndarray of position angles
        ba : np.float32
            ndarray of minor-to-major (b/a) axis ratios

        Notes
        -----
        Infers the following:
            indx
            nx, ny
            dxcen, dycen
            xcen, ycen
        """
        dtype = [('indx', np.int32),
                 ('nx', np.int32),
                 ('ny', np.int32),
                 ('dxcen', np.float32),
                 ('dycen', np.float32),
                 ('xcen', np.float32),
                 ('ycen', np.float32),
                 ('flux', np.float32),
                 ('r50', np.float32),
                 ('n', np.float32),
                 ('phi', np.float32),
                 ('ba', np.float32)
                 ]
        data = np.empty(len(flux), dtype=dtype)
        data['indx'] = np.arange(len(flux))
        data['flux'] = flux
        data['r50'] = r50
        data['n'] = n
        data['phi'] = phi
        data['ba'] = ba

        # Determine jitter
        for i in np.arange(len(data)):
            data['dxcen'] = - 0.5 + random.uniform(0., 1.)
            data['dycen'] = - 0.5 + random.uniform(0., 1.)

        # Determine sizes and centers based on Sersic parameters
        size = np.int32(2 * np.int32(rlimit(data['n']) *
                                     data['r50']) + 1)
        ilow = np.where(size < 151)
        size[ilow] = 151
        data['nx'] = size
        data['ny'] = size
        data['xcen'] = np.float32(size / 2) + data['dxcen']
        data['ycen'] = np.float32(size / 2) + data['dycen']

        self.params = data
