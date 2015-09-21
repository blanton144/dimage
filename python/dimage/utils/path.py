import urllib2
import os
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

class path(base_path):
    """Class for construction of NASA-Sloan Atlas paths
    """
    def __init__(self):
        pathfile=os.path.join(os.getenv('DIMAGE_DIR'),
                              'data', 'dimage_paths.ini')
        super(path,self).__init__(pathfile)

    def vN(self, filetype, **kwargs):
        try:
            return version_to_topdir(kwargs['version'])
        except KeyError:
            return None

    def vN_M(self, filetype, **kwargs):
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
        nsaid= self.iauname_to_nsaid(iauname)
        return self.nsaid_to_pid(nsaid)[0][0]

    def aid(self, filetype, **kwargs):
        iauname= self.iauname(filetype, **kwargs)
        nsaid= self.iauname_to_nsaid(iauname)
        pid= self.nsaid_to_pid(nsaid)[0][0]
        return self.nsaid_to_aid(nsaid,pid)[0][0]
        
        # For paths with IAUNAME, deal with PID identifiers
        if "[pid]" in template: 
            template=template.replace('[pid]', str(pid))
            # And if PID is needed, get AID too
            if "[aid]" in template: 
                aid= self.nsaid_to_aid(nsaid, pid)[0]
                template=template.replace('[aid]', str(aid))
        
class access(object):
    """
    Class for accessing remote (http) or local data identically

    Attributes:
    ==========
    _type : 'local' or 'http'
    localdir : Local base directory for access
    baseurl : Base url for http access
    username : User name for http access
    password : Password for http access
    cache : bool, whether to cache results for download_file

    Methods:
    =======

    local() - Sets a local source of data (overrides) 
    http() - Sets a remote http source of data

    open() - Open a file for reading from remote or local
    copy() - Copy a file from remote or local

    Notes:
    =====

    May be useful for other applications, but for NSA normally you
    should just use the atlas class.

    Depends on urllib2, os, and astropy v1.0 or later. Specifically it
    uses astropy.utils.data.download_file to handle remote access. The
    only nontrivial part of this is the password handling.

    To use caching, you may need to run (once):
    
    import astropy.config
    astropy.config.get_cache_dir
    
    which should create '~/.astropy/cache'
    """

    _type='local'
    cache=True

    def http(self, baseurl=None, username=None, password=None,
             urlfile=None):
        """
        Sets up class for remote access

        Parameters:
        ==========

        baseurl : url to serve as base for remote access
        username : user name for password access
        password : password for password access
        urlfile : three-line file with baseurl, password, urlfile

        """

        # Read info from urlfile
        if(urlfile is not None):
            try:
                fp=file.open(urlfile)
                self.baseurl=fp.readline()
                self.username=fp.readline()
                self.password=fp.readline()
                fp.close()
            except:
                print "Problem with URL file "+urlfile+", not setting remote."
                return
        
        try:
            # this creates a password manager
            passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
            passman.add_password(None, self.baseurl, self.username, 
                                 self.password)
            # create the AuthHandler
            authhandler = urllib2.HTTPBasicAuthHandler(passman)
            opener = urllib2.build_opener(authhandler)
            # All calls to urllib2.urlopen will now use our handler
            # Make sure not to include the protocol in with the URL, or
            # HTTPPasswordMgrWithDefaultRealm will be very confused.
            # You must (of course) use it when fetching the page though.
            urllib2.install_opener(opener)
            self._type='http'
        except:
            print "Problem opening URL "+self.baseurl
            
    def local(self, localdir):
        """
        Method to set up access class for local access
        
        Parameters:
        ==========
        localdir : top-level local directory for access point
        """
        self.localdir= localdir
        self._type='local'

    def _open_http(self, filename):
        """
        Internal method to open file with http
        """
        return data.download_file(filename, cache=self.cache)

    def _open_local(self, filename):
        """
        Internal method to open file locally
        """
        return file(filename, 'rb')

    def open(self, filename):
        """
        Method to open file

        Parameters:
        ==========
        
        filename : file name

        Notes:
        =====

        If type of access set to http, opens [baseurl]/[filename]
        If type of access set to local, opens [localdir]/[filename]

        """
        if(self._type == 'local'):
            return self._open_local(filename)
        if(self._type == 'http'):
            return self._open_http(filename)
            
    def copy(self, filename, outfile=None):
        """
        Method to copy file

        Parameters:
        ==========
        
        filename : file name
        outfile : output file

        Notes:
        =====
        
        Calls open() method

        """
        if(outfile is None):
            outfile= filename.split('/')[-1]
        ifp=self.open(filename)
        ofp=file(outfile, 'wb')
        ofp.write(ifp.read())
        ifp.close()
        ofp.close()
        return None


class atlas(access):
    """
    Class for accessing remote or local data identically

    Attributes:
    ==========
    type : 'local' or 'http'
    localdir : Local base directory for access
    baseurl : Base url for http access
    username : User name for http access
    password : Password for http access
    version : version number of atlas
    cache : bool, whether or not to cache in astropy's download_file

    Methods:
    =======

    local() - Sets a local source of atlas data (overrides) 
    http() - Sets a http source of atlas data

    open() - Open a file for reading from remote or local
    copy() - Copy a file from http or local

    filedir() - Return directory of a file
    filename() - Return name of a file
    file() - Return a file
    """

    _type='local'
    baseurl= 'http://data.mirror.sdss.org/sas/sdsswork/atlas'
    username = 'sdss'
    password = '2.5-meters'
    localdir = os.getenv('ATLAS_DATA')
    version= 'v1_0_0'
    nsaid_to_iauname_dict= None
    iauname_to_nsaid_dict= None
    cache=True

    def _reset(self):
        self.nsaid_to_iauname_dict=None
        self.iauname_to_nsaid_dict=None
        
    def local(self, localdir=None):
        """
        Sets up access class for local access based on $ATLAS_DATA

        Parameters:
        ==========
        localdir : if set, overrides $ATLAS_DATA
        """
        if(localdir is None):
            self.localdir= os.getenv('ATLAS_DATA')
        else:
            self.localdir= localdir
        self._type='local'
        self._reset()

    def nsaid_init(self):
        """
        Initializes translation table from NSAID to IAUNAME
        """
        atlas=fits.open(self.file('atlas'))
        iauname=atlas[1].data['IAUNAME']
        nsaid=range(len(iauname))
        self.nsaid_to_iauname_dict= dict(zip(nsaid, iauname))
        self.iauname_to_nsaid_dict= dict(zip(iauname, nsaid))
        atlas.close()

    def nsaid_to_iauname(self, nsaid, **kwargs):
        """
        Returns IAUNAME given NSAID

        Parameters:
        ==========
        nsaid : int, NSAID to infer IAUNAME from

        Notes:
        =====
        Uses translation table set up by nsaid_init(),
        which involves reading the original atlas.fits file.
        Large overhead on first call.
        """
        if self.nsaid_to_iauname_dict is None:
            self.nsaid_init()
        return self.nsaid_to_iauname_dict[nsaid]

    def nsaid_to_pid(self, nsaid, **kwargs):
        """
        Returns PID value for NSAID

        Parameters:
        ==========
        nsaid : int, NSAID 
        
        Returns:
        =======
        pid : parent IDs of processed objects in image
        """
        pcat= fits.open(self.file('pcat', nsaid=nsaid))
        # Infers from where CRA isn't zero
        indx= np.nonzero(pcat[1].data['CRA'])
        return indx

    def nsaid_to_aid(self, nsaid, pid, **kwargs):
        """
        Returns AID values for NSAID/PID

        Parameters:
        ==========
        nsaid : int, NSAID 
        pid : parent ID 
        
        Returns:
        =======
        aid : aid to use
        """
        measure= fits.open(self.file('measure', pid=pid, nsaid=nsaid))
        # Infers from where measurements exist
        aid= measure[1].data['AID']
        return aid

    def iauname_to_nsaid(self, iauname, **kwargs):
        """
        Returns IAUNAME given NSAID
        """
        if self.iauname_to_nsaid_dict is None:
            self.nsaid_init()
        return self.iauname_to_nsaid_dict[iauname]

    def filename(self, filetype, **kwargs):
        """
        Method to return full name a given type of file
        Takes same parameters as atlas.file()
        """

        template= path[filetype]
        if(self._type  == 'local'):
            template=os.path.join(self.localdir, template)
        else:
            template=os.path.join(self.baseurl, template)

        # Determine and replace basic directories
        topdir= version_to_topdir(self.version)
        template=template.replace('[vN]', topdir)
        detectdir= version_to_detectdir(self.version)
        template=template.replace('[vN_M]', detectdir)
        
        # Deal with IAUNAME identifiers
        iauname= None
        if kwargs.has_key('iauname'): # Set IAUNAME if given
            iauname=kwargs['iauname']
        else: # Use NSAID/RADEC to deduce IAUNAME if need be
            if kwargs.has_key('ra') and kwargs.has_key('dec'):
                iauname= radec_to_iauname(**kwargs)
            if kwargs.has_key('nsaid'):
                iauname= self.nsaid_to_iauname(**kwargs)
        if iauname is not None:
            # set subdirectories
            subdir= iauname_to_subdir(iauname)
            template=template.replace('[iauname]', iauname)
            template=template.replace('[subdir]', subdir)
        
            # For paths with IAUNAME, deal with PID identifiers
            if "[pid]" in template: 
                nsaid= self.iauname_to_nsaid(iauname)
                pid= self.nsaid_to_pid(nsaid)[0][0]
                template=template.replace('[pid]', str(pid))
                # And if PID is needed, get AID too
                if "[aid]" in template: 
                    aid= self.nsaid_to_aid(nsaid, pid)[0]
                    template=template.replace('[aid]', str(aid))

        # Now replace 
        exclude_list=[]
        for key, value in kwargs.iteritems():
            if exclude_list.count(key) == 0:
                template=template.replace('['+key+']', str(value))
        
        return template

    def filedir(self, filetype, **kwargs):
        """
        Method to return directory of a given type of file
        Takes same parameters as atlas.file()
        """
        filename=self.filename(filetype, **kwargs)
        return "/".join(filename.split('/')[0:-1])

    def file(self, filetype, outfile=None, **kwargs):
        """
        Method to open or copy a specific file

        Parameters:
        =======
        filetype : type of file to return 
        keyword arguments for replacement:
           nsaid, or iauname, or ra and dec
           band 
        outfile : Output file if a copy desired (default None)

        Notes:
        =====
        Depends on version attribute (should be of form vN_M_P)
        Accepted file types:
           'atlas'
           'mosaic' (specify identifier and band)
        """

        filename= self.filename(filetype, **kwargs)
        if(outfile is None):
            return self.open(filename)
        else:
            return self.copy(filename)
