import urllib2
import os
import astropy.coordinates as coordinates
import astropy.utils.data as data
import astropy.io.fits as fits

"""
Module for accessing NASA-Sloan Atlas images and catalogs, either
locally or remotely.

Use the "atlas" class to set up an access point for the data. You can
set the version of atlas and also set up the access information for
it. By default, it assumes the data is local, in the root directory is
in $ATLAS_DATA (an environmental variable).

If the data is remote, the remote access point can be set using the
http() method.

For example, to access the mosaic for an NSA object with IAUNAME
locally that is in $ATLAS_DATA:

nsa= atlas()
nsa.version= 'v1_0_0'
mosaic= nsa.mosaic(iauname, band='g') 

To access the same mosaic remotely:

from dimage.atlas import atlas
nsa= atlas()
nsa.version= 'v1_0_0'
nsa.http()
mosaic= pyfits.open(nsa.mosaic('J095641.38+005057.1', band='g'))

The above uses the default http settings. You can instead include them
as parameters, as shown below:

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

To use caching, you may need to run (once):

import astropy.config
astropy.config.get_cache_dir

which should create '~/.astropy/cache'

"""

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
        url= self.baseurl+'/'+filename
        return data.download_file(url, cache=self.cache)

    def _open_local(self, filename):
        """
        Internal method to open file locally
        """
        return file(os.path.join(self.localdir,filename), 'rb')

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
    
def radec_to_iauname(ra, dec):
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

def iauname_to_subdir(iauname):
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

    mosaic() - Open or copy a mosaic file
    mosaic_file() - Return file name of a mosaic file
    mosaic_path() - Return path to a mosaic file
    
    atlas() - Open or copy atlas.fits file from NSA
    atlas_file() - File name (full path) of atlas.fits

    To use caching, you may need to run (once):
    
    import astropy.config
    astropy.config.get_cache_dir
    
    which should create '~/.astropy/cache'
    
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
        atlas=fits.open(self.atlas())
        iauname=atlas[1].data['IAUNAME']
        nsaid=range(len(iauname))
        self.nsaid_to_iauname_dict= dict(zip(nsaid, iauname))
        self.iauname_to_nsaid_dict= dict(zip(iauname, nsaid))
        atlas.close()

    def nsaid_to_iauname(self, nsaid):
        """
        Returns IAUNAME given NSAID

        Parameters:
        ==========
        
        """
        if self.nsaid_to_iauname_dict is None:
            self.nsaid_init()
        return self.nsaid_to_iauname_dict[nsaid]

    def iauname_to_nsaid(self, iauname):
        """
        Returns IAUNAME given NSAID
        """
        if self.iauname_to_nsaid_dict is None:
            self.nsaid_init()
        return self.iauname_to_nsaid_dict[iauname]

    def id_to_iauname(self, id, id_type='IAUNAME'):
        """
        Function to convert id to an IAUNAME
        
        Parameters:
        ==========
        id : Identifier (IAUNAME or (RA,DEC) tuple)
        id_type : Type of identifier for id_to_iauname() (default 'IAUNAME')
        
        Returns:
        =======
        IAU-style name corresponding to ID (JHHMMSS.SS[+-]DDMMSS.S)
        
        Notes:
        ======
        Accepts types 'IAUNAME', 'NSAID', and 'RADEC'.
        """
        if(id_type == 'IAUNAME'):
            return id
        if(id_type == 'RADEC'):
            return radec_to_iauname(id[0], id[1])
        if(id_type == 'NSAID'):
            return self.nsaid_to_iauname(id)
        
    def atlas_file(self):
        """
        Method to return path to atlas.fits

        Returns:
        =======
        filename : path to directory with atlas.fits file defining 
                   major version vN/catalogs/atlas.fits
        """
        return os.path.join(version_to_topdir(self.version), 
                            'catalogs', 'atlas.fits')

    def atlas(self, outfile=None):
        """
        Method to return atlas.fits

        Parameters:
        ==========
        outfile : Output file if a copy desired (default None)

        Returns:
        =======
        atlas : file object with atlas.fits in it

        Notes:
        =====
        Depends on version attribute (should be of form vN_M_P)
        If outfile specified, file copied to outfile, None returned
        """
        atlasfile= self.atlas_file()
        if(outfile is None):
            return self.open(atlasfile)
        else:
            return self.copy(atlasfile)

    def mosaic_path(self, id, mosaic_type='detect', **kwargs):
        """
        Method to return path to directory with mosaic

        Parameters:
        ==========
        
        id : Identifier (IAUNAME or (RA,DEC) tuple)
        mosaic_type : Subdirectory of mosaics (default 'detect')
        id_type : Type of identifier for id_to_iauname() (default 'IAUNAME')

        Returns:
        =======
        path : path to directory with mosaic:
                 vN/[mosaic_type]/vN_M/[RA]/[DEC]/[IAUNAME]
         where RA is 00h, 01h, etc. and DEC is [..., m02, m00, p00, p02, ...]

        Notes:
        =====
        Depends on version attribute (should be of form vN_M_P)
        Accepts id_type values of 'IAUNAME', 'RADEC' and 'NSAID'
        """
        topdir= version_to_topdir(self.version)
        detectdir= version_to_detectdir(self.version)
        iauname= self.id_to_iauname(id, **kwargs)
        subdir= iauname_to_subdir(iauname)
        return os.path.join(topdir, mosaic_type, detectdir, subdir)
    
    def mosaic_file(self, id, band='r', **kwargs):
        """
        Method to return path to directory with mosaic

        Parameters:
        ==========
        
        id : Identifier (IAUNAME or (RA,DEC) tuple)
        band : Band name (default 'r')
        mosaic_type : Subdirectory of mosaics (default 'detect')
        id_type : Type of identifier for id_to_iauname() (default 'IAUNAME')

        Returns:
        =======
        file : filename with mosaic:
          vN/[mosaic_type]/vN_M/[RA]/[DEC]/[IAUNAME]/[IAUNAME]-[BAND].fits.gz
         where RA is 00h, 01h, etc. and DEC is [..., m02, m00, p00, p02, ...]

        Notes:
        =====
        Depends on version attribute (should be of form vN_M_P)
        Accepts id_type values of 'IAUNAME', 'RADEC' and 'NSAID'
        """
        mosaic_dir= self.mosaic_path(id, **kwargs)
        iauname= self.id_to_iauname(id, **kwargs)
        mosaic_file= iauname+'-'+band+'.fits.gz'
        mosaic_full= os.path.join(mosaic_dir, mosaic_file)
        return mosaic_full

    def mosaic(self, id, outfile=None, **kwargs):
        """
        Method to return path to directory with mosaic

        Parameters:
        ==========
        
        id : Identifier (IAUNAME or (RA,DEC) tuple)
        band : Band name (default 'r')
        mosaic_type : Subdirectory of mosaics (default 'detect')
        id_type : Type of identifier for id_to_iauname() (default 'IAUNAME')
        outfile : Output file if a copy desired (default None)

        Returns:
        =======
        file : file object with mosaic

        Notes:
        =====
        Depends on version attribute (should be of form vN_M_P)
        If outfile specified, file copied to outfile, None returned
        Accepts id_type values of 'IAUNAME', 'RADEC' and 'NSAID'
        """
        mosaic_full= self.mosaic_file(id, **kwargs)
        if(outfile is None):
            return self.open(mosaic_full)
        else:
            return self.copy(mosaic_full)
