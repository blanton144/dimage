import os
import numpy as np
import fitsio


def impose(image=None, parameters=None):
    import dimage.fake.conditions as conditions
    names = parameters.dtype.names
    ftypes = ['background', 'psf', 'resample', 'calibration']
    new_image = np.zeros(image.shape)
    new_image[:, :] = image[:, :]
    for ftype in ftypes:
        if(ftype + '_function' in names):
            module = getattr(conditions, ftype)
            func = getattr(module, parameters[ftype + '_function'].strip())
            new_image = func(new_image, parameters)
    module = getattr(conditions, 'noise')
    func = getattr(module, parameters['noise_function'].strip())
    (new_image, new_ivar) = func(new_image, parameters)
    return (new_image, new_ivar)


def impose_file(image_file=None, conditions_file=None, new_file=None):
    conditions = fitsio.read(conditions_file)
    parameters = np.random.choice(conditions)
    (image, header) = fitsio.read(image_file, header=True)
    (new_image, new_ivar) = impose(image=image, parameters=parameters)
    dirname = os.path.dirname(new_file)
    if(os.path.isdir(dirname) is False):
        os.makedirs(dirname)
    fitsio.write(new_file, new_image, header=header, clobber=True)
    fitsio.write(new_file, new_ivar, header=header)
