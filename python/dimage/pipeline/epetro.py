"""
Calculate an approximate

Michael R. Blanton, 2014-05-14
"""

import fitsio
import dimage.measure.petro as petro


def epetro(imagefile=None, outfile=None):
    """Runs elliptical Petrosian measurements on a file

    Parameters
    ----------
    imagefile : string
        full path file name of image to input
    outfile : string
        full path file name of file to store outputs

    """
    image = fitsio.read(imagefile, ext=0)
    ivar = fitsio.read(imagefile, ext=1)

    petro_params = petro(image, ivar)

    petro_dtype = [('flux', np.float32),
                   ('ivar', np.float32),
                   ('petrorad', np.float32),
                   ('r50', np.float32),
                   ('r90', np.float32)]
    petro_results = np.empty(1, dtype=petro_dtype)
    petro_results['flux'] = petro_params['flux']
    petro_results['ivar'] = petro_params['ivar']
    petro_results['petrorad'] = petro_params['petrorad']
    petro_results['r50'] = petro_params['r50']
    petro_results['r90'] = petro_params['r90']

    return apcorr
