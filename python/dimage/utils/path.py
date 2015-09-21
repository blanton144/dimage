import urllib2
import os
import re
import numpy as np
import astropy.coordinates as coordinates
import astropy.utils.data as data
import astropy.io.fits as fits
from sdss.files.path import base_path

"""
Module for accessing NASA-Sloan Atlas images and catalogs, either
locally or remotely.

Use the "atlas" class to set up an access point for the data. You can
set the version of atlas and also set up the access information for
it. By default, it assumes the data is local, and the root directory
is in $ATLAS_DATA (an environmental variable).

For example, to access the mosaic for an NSA object with IAUNAME
locally that is in $ATLAS_DATA:

from dimage.atlas import atlas
nsa= atlas()
nsa.version= 'v1_0_0'
mosaic= pyfits.open(nsa.file('mosaic', iauname='J095641.38+005057.1', band='g'))

To access the same mosaic remotely:

from dimage.atlas import atlas
nsa= atlas()
nsa.version= 'v1_0_0'
nsa.http()
mosaic= pyfits.open(nsa.file('mosaic', iauname='J095641.38+005057.1', band='g'))
mosaic= pyfits.open(nsa.file('mosaic', nsaid=15555, band='i'))
mosaic= pyfits.open(nsa.file('mosaic', ra=15., dec=24., band='i'))

The other sorts of files accessible are:

nsa.file('atlas') - original atlas.fits file defining major version

The example above uses the default http settings. You can instead
include them as parameters, as shown below:

nsa.http(baseurl=baseurl, username=username, password=password)

If you need to return to local access, you can reset the object to
local access:

nsa.local(localdir=localdir)

where if localdir is not given or None then $ATLAS_DATA is assumed.

Several functions in this module may be of more general use (but
should usually only be used by functions in the atlas class):

  version_to_topdir()
  version_to_detectdir()
  radec_to_iauname()
  iauname_to_subdir()
  
The "atlas" class is a subclass of "access", which wraps the switch
between local and remote. "access" may be useful in other contexts
(though it is just a very thin layer over urllib2).

Depends on urllib2, os, and astropy v1.0 or later. Specifically it
uses astropy.utils.data.download_file to handle remote access.

To have astropy.utils.data use caching, you may need to run (once):

import astropy.config
astropy.config.get_cache_dir

which should create '~/.astropy/cache'

"""

def version_to_topdir(version):
    """
    Function to convert version into top directory of atlas

    Parameters:
    ==========
    version : version of NSA (vN_M_P)

    Returns:
    =======
    topid : top directory name vN
    """
    vN= (version.split('_'))[0]
    return vN

def version_to_detectdir(version):
    """
    Function to convert version into detection subdirectory

    Parameters:
    ==========
    version : version of NSA (vN_M_P)

    Returns:
    =======
    detectdir : detection subdirectory vN_M
    """
    vNM= "_".join((version.split('_'))[0:2])
    return vNM
    
def radec_to_iauname(ra, dec, **kwargs):
    """
    Function to convert RA, Dec to an IAU-style name (JHHMMSS.SS[+-]DDMMSS.S)

    Parameters:
    ==========
    ra : Right ascension, in deg
    dec : Declination, in deg

    Returns:
    =======
    iauname : IAU-style name corresponding to ID (JHHMMSS.SS[+-]DDMMSS.S)
    """
    precision=2
    ra_angle= coordinates.Angle(ra, unit='degree')
    rastr= ra_angle.to_string(unit='hour', sep='', precision=precision,
                              pad=True)
    dec_angle= coordinates.Angle(dec, unit='degree')
    decstr= dec_angle.to_string(unit='degree', sep='', precision=precision-1,
                                pad=True, alwayssign=True)
    return 'J'+rastr+decstr

def iauname_to_subdir(iauname, **kwargs):
    """
    Function to convert IAUNAME to a subdirectory in NSA

    Parameters:
    ==========
    iauname : IAU-style name corresponding to ID (JHHMMSS.SS[+-]DDMMSS.S)

    Returns:
    =======
    subdir : subdirectory based on IAU-style name
        [RA]/[DEC]/[IAUNAME]
      where RA is 00h, 01h, etc. and DEC is [..., m02, m00, p00, p02, ...]
    """
    ra_dir= iauname[1:3]+'h'
    dec_dir= "%02d" % (int(abs(float(iauname[11:13]))/2.)*2)
    if iauname[10] == '+':
        dec_dir= 'p'+dec_dir
    else:
        dec_dir= 'm'+dec_dir
    return os.path.join(ra_dir, dec_dir, iauname)

def local_to_url(local, local_base='/data', remote_base='http://data.sdss.org'):
    """
    Function to convert a local path to the remote URL
    
    Parameters:
    ==========

    local : path to convert

    local_base : Base path on local system

    remote_base : Corresponding base path on remote system

    """
    return re.sub("^"+local_base, remote_base, local)

def download_file(url, filename):
    if(os.path.isfile(filename) is True):
        return filename

    filedir= os.path.dirname(filename)
    if(os.path.isdir(filedir) is False):
        os.makedirs(filedir)

    u = urllib2.urlopen(url)
    
    with open(filename, 'wb') as f:
        meta = u.info()
        meta_func = meta.getheaders if hasattr(meta, 'getheaders') else meta.get_all
        meta_length = meta_func("Content-Length")
        file_size = None
        if meta_length:
            file_size = int(meta_length[0])
        print("Downloading: {0} Bytes: {1}".format(url, file_size))

        file_size_dl = 0
        block_sz = 8192
        while True:
            buffer = u.read(block_sz)
            if not buffer:
                break

            file_size_dl += len(buffer)
            f.write(buffer)

    return filename

class path(base_path):
    """Class for construction of NASA-Sloan Atlas paths
    """

    def __init__(self):
        pathfile=os.path.join(os.getenv('DIMAGE_DIR'),
                              'data', 'dimage_paths.ini')
        super(path,self).__init__(pathfile)
        self.nsaid_to_iauname_dict= None
        self.iauname_to_nsaid_dict= None
        self.remote_base='http://data.sdss.org'
        self.local_base='/data'
        self._remote= False

    def _reset(self):
        self.nsaid_to_iauname_dict=None
        self.iauname_to_nsaid_dict=None

    def _nsaid_init(self, **kwargs):
        """
        Initializes translation table from NSAID to IAUNAME
        """
        atlas=fits.open(self.get('atlas', version=kwargs['version']))
        iauname=atlas[1].data['IAUNAME']
        nsaid=range(len(iauname))
        self.nsaid_to_iauname_dict= dict(zip(nsaid, iauname))
        self.iauname_to_nsaid_dict= dict(zip(iauname, nsaid))
        atlas.close()

    def remote(self, remote_base=None, local_base=None,
               username=None, password=None):
        if(remote_base is not None):
            self.remote_base= remote_base
        if(local_base is not None):
            self.local_base= local_base
        self._remote= True
        if((username is not None) and (password is not None)):
            passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
            passman.add_password(None, self.remote_base, 
                                 username, password)
            authhandler = urllib2.HTTPBasicAuthHandler(passman)
            opener = urllib2.build_opener(authhandler)
            urllib2.install_opener(opener)

    def nsaid_to_iauname(self, nsaid, **kwargs):
        """
        Returns IAUNAME given NSAID

        Parameters:
        ==========
        nsaid : int
          NSAID to infer IAUNAME from

        Notes:
        =====
        Uses translation table set up by _nsaid_init(),
        which involves reading the original atlas.fits file.
        Large overhead on first call.
        """
        if self.nsaid_to_iauname_dict is None:
            self._nsaid_init(**kwargs)
        return self.nsaid_to_iauname_dict[nsaid]

    def iauname_to_nsaid(self, iauname, **kwargs):
        """
        Returns NSAID given IAUNAME

        Parameters:
        ==========
        IAUNAME : str
          IAUNAME to infer NSAID from

        Notes:
        =====
        Uses translation table set up by _nsaid_init(),
        which involves reading the original atlas.fits file.
        Large overhead on first call.
        """
        if self.iauname_to_nsaid_dict is None:
            self.nsaid_init()
        return self.iauname_to_nsaid_dict[iauname]

    def nsaid_to_pid(self, nsaid, **kwargs):
        """
        Returns PID value for NSAID


        
        Parameters:
        ==========
        nsaid : int
          NSAID 
        
        Returns:
        =======
        pid : int
          parent IDs of processed objects in image
        """
        pcat= fits.open(self.get('pcat', nsaid=nsaid, **kwargs))
        # Infers from where CRA isn't zero
        indx= np.nonzero(pcat[1].data['CRA'])
        return indx

    def nsaid_to_aid(self, nsaid, pid, **kwargs):
        """
        Returns AID values for NSAID/PID

        Parameters:
        ==========
        nsaid : int
          NSAID 
        pid : int 
          parent ID 
        
        Returns:
        =======
        aid : aid to use
        """
        measure= fits.open(self.get('measure', pid=pid, nsaid=nsaid,
                                    **kwargs))
        # Infers from where measurements exist
        aid= measure[1].data['AID']
        return aid

    def local(self):
        self._remote= False

    def v1(self, filetype, **kwargs):
        try:
            return version_to_topdir(kwargs['version'])
        except KeyError:
            return None

    def v2(self, filetype, **kwargs):
        try:
            return version_to_detectdir(kwargs['version'])
        except KeyError:
            return None
    
    def iauname(self, filetype, **kwargs):    
        if kwargs.has_key('iauname'): # Set IAUNAME if given
            return kwargs['iauname']
        else: # Use NSAID/RADEC to deduce IAUNAME if need be
            if kwargs.has_key('ra') and kwargs.has_key('dec'):
                return radec_to_iauname(**kwargs)
            if kwargs.has_key('nsaid'):
                return self.nsaid_to_iauname(**kwargs)

    def subdir(self, filetype, **kwargs):
        iauname= self.iauname(filetype, **kwargs)
        return iauname_to_subdir(iauname)

    def pid(self, filetype, **kwargs):
        iauname= self.iauname(filetype, **kwargs)
        kwargs['nsaid']= self.iauname_to_nsaid(iauname)
        return str(self.nsaid_to_pid(**kwargs)[0][0])

    def aid(self, filetype, **kwargs):
        iauname= self.iauname(filetype, **kwargs)
        kwargs['nsaid']= self.iauname_to_nsaid(iauname)
        kwargs['pid']= self.nsaid_to_pid(**kwargs)[0][0]
        return str(self.nsaid_to_aid(**kwargs)[0])

    def url(self, filetype, **kwargs):
        filename=self.full(filetype, **kwargs)
        return(local_to_url(filename, local_base=self.local_base,
                            remote_base=self.remote_base))
        
    def get(self, filetype, **kwargs):
        filename= self.full(filetype, **kwargs)
        if(self._remote is True):
            download_file(self.url(filetype, **kwargs), filename)
        return(filename)
