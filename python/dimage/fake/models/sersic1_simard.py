"""
Sersic 1D model utilities
"""

import numpy as np
import random
import os
import scipy
import fitsio
from dimage.fake.models.sersic1 import Sersic1


def rlimit(n, frac=0.99):
    bn = scipy.special.gammaincinv(2. * n, 0.5)
    return (scipy.special.gammaincinv(2. * n, frac) / bn)**n


class Sersic1_Simard(Sersic1):
    def __init__(self, take=None, read=False):
        modelname = 'sersic1_simard'
        super(Sersic1_Simard, self).__init__(take=take, modelname=modelname,
                                             read=False)
        self.create()

    def read_simard(self):
        simfile = os.path.join(os.getenv('DIMAGE_DATA'),
                               'comparison',
                               'simard-sdss-pn.fits')
        return fitsio.read(simfile)

    def select_good(self, data=None):
        indx = (np.where((data['Scale'] > 0) * (data['rg2d'] < 17.5) *
                         (data['Rhlr'] > 0) * (data['Rhlr'] > 1.) *
                         (data['ng'] < 7.)))[0]
        return data[indx]

    def create(self):
        # Select galaxies
        data = self.read_simard()
        data = self.select_good(data)
        seed = self.take_params['seed']
        nmodel = self.nmodel
        random.seed(seed)
        random.shuffle(data)
        data = data[0:nmodel]
        arcsec_per_pixel = np.float32(self.take_params['arcsec_per_pixel'])
        r50 = data['Rhlr'] / data['Scale'] / arcsec_per_pixel
        flux = 10.**(0.4 * (22.5 - data['rg2d']))
        n = data['ng']
        ba = 1. - data['e']
        phi = data['phi']
        self.set_params(flux=flux, r50=r50, n=n, phi=phi, ba=ba)
