import numpy as np
import astropy.wcs as wcs


def wcssimple(ra, dec, size, pixscale):
    """Create simple astropy WCS object, with TAN projection.

    Parameters
    ----------
    ra, dec : float
        center of image (J2000 deg)
    size : float
        size of square image (deg)
    pixscale : float
        pixel scale (arcsec)

    Returns
    -------
    (wcs, nx, ny) : (WCS, int, int)
        WCS object and dimensions of image

    Notes
    -----
    Return North (+y), East (+x) image; no rotation.

    """

    w = wcs.WCS(naxis=2)
    naxis1 = np.int32(size / (pixscale / 3600.))
    naxis2 = naxis1
    xmid = naxis1 // 2
    ymid = naxis2 // 2
    w.wcs.crpix = [xmid + 1, ymid + 1]
    w.wcs.cdelt = np.array([-pixscale / 3600., pixscale / 3600.])
    w.wcs.crval = [ra, dec]
    w.wcs.ctype = ["RA---TAN", "DEC--TAN"]

    return (w, naxis1, naxis2)
