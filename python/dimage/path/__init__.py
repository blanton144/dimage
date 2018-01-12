"""
Package for accessing NASA-Sloan Atlas locally or remotely.

Includes the Path class. It requires the environmental variable
$ATLAS_DATA to be set to the root of the NSA data tree, and finds
templates for the file paths in $DIMAGE_DIR/data/dimage_paths.ini. The
Path class has the method get() which returns the file name.

A typical use case will be::

    import fitsio
    import dimage.path
    apath= dimage.path.Path()
    filename= apath.get('original', iauname='J095641.38+005057.1', band='g',
                         survey='sdss', version='v1_0_0')
    image= fitsio.read(filename)

To access the same mosaic remotely, the code will download from
the server at http://data.sdss.org into your local $ATLAS_DATA
directory. Then you will be able to access the file::

    import dimage.path
    apath= dimage.path.Path()
    # insert SDSS username and password as strings below!
    apath.remote(username=, password=)
    filename= apath.get('original', iauname='J095641.38+005057.1', band='g',
                         survey='sdss', version='v1_0_0')
    image= fitsio.read(filename)

The remote access configuration will build local "mirror" under
$ATLAS_DATA of the remote site consisting of just the files that have
been requested. This mirror is used as a cache and files are not
downloaded again if they already appear there. This cache needs to be
cleared manually to force a download.

The template paths are defined as follows:
 - pieces enclosed in {} are interpreted according to python's string
   format() method, using input keywords
 - environmental variables indicated by $ are substituted
 - defined special functions can be called with % (they are given
   the input keywords)

For example, the location of one of the original images for NASA-Sloan
Atlas analysis is defined as::

  original= $ATLAS_DATA/%v1/detect/{survey}/%subdir/%iauname-{band}.fits.gz

Depends on urllib2, os, sdss, and astropy v1.0 or later. In
particular, within sdss it utilizes the base_path class in
sdss.files.path.
"""

from .path import *
