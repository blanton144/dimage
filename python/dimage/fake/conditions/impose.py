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
            func = getattr(module, parameters[ftype + '_function'][0].strip())
            new_image = func(new_image, parameters)
    return new_image


def impose_file(image_file=None, conditions_file=None, new_file=None):
    conditions = fitsio.read(conditions_file)
    image = fitsio.read(image_file)
    new_image = impose(image=image, parameters=conditions)
    fitsio.write(new_file, new_image)
