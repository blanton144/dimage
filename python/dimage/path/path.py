import os
import re
import numpy as np
import fitsio
import requests
from .base_path import base_path


def version_to_topdir(version):
    """
    Convert version name into top directory of atlas

    Parameters
    ----------
    version : str
        version of NSA (vN_M_P)

    Returns
    -------
    topid :  str
        top directory name vN
    """
    vN = (version.split('_'))[0]
    return vN


def version_to_detectdir(version):
    """
    Convert version name into detection subdirectory

    Parameters
    ----------
    version : str
        version of NSA (vN_M_P)

    Returns
    -------
    detectdir : str
        detection subdirectory vN_M
    """
    vNM = "_".join((version.split('_'))[0:2])
    return vNM


def radec_to_iauname(ra, dec, **kwargs):
    """
    Function to convert RA, Dec to an IAU-style name (JHHMMSS.SS[+-]DDMMSS.S)

    Parameters
    ----------
    ra : float
        Right ascension, in deg
    dec : float
        Declination, in deg

    Returns
    -------
    iauname : str
        IAU-style name corresponding to ID (JHHMMSS.SS[+-]DDMMSS.S)
    """
    import astropy.coordinates as coordinates
    precision = 2
    ra_angle = coordinates.Angle(ra, unit='degree')
    rastr = ra_angle.to_string(unit='hour', sep='', precision=precision,
                               pad=True)
    dec_angle = coordinates.Angle(dec, unit='degree')
    decstr = dec_angle.to_string(unit='degree', sep='',
                                 precision=precision - 1,
                                 pad=True, alwayssign=True)
    return 'J' + rastr + decstr


def iauname_to_subdir(iauname, **kwargs):
    """
    Convert IAUNAME to a subdirectory name in NASA-Sloan Atlas

    Parameters
    ----------
    iauname : str
        IAU-style name corresponding to ID (JHHMMSS.SS[+-]DDMMSS.S)

    Returns
    -------
    subdir : str
        subdirectory based on IAU-style name

    Notes
    -----
    Subdirectory is of the form: [RA]/[DEC]/[IAUNAME],
    where RA is 00h, 01h, etc. and DEC is [..., m02, m00, p00, p02, ...]
    """
    ra_dir = iauname[1:3].decode() + 'h'
    dec_dir = "%02d" % (int(abs(float(iauname[11:13])) / 2.) * 2)
    if str(iauname)[12] == "+":
        dec_dir = 'p' + dec_dir
    else:
        dec_dir = 'm' + dec_dir
    return os.path.join(ra_dir, dec_dir, iauname.decode())


def local_to_url(local, local_base='/data',
                 remote_base='http://data.sdss.org'):
    """
    Convert a local path to the remote URL

    Parameters
    ----------

    local : str
        path to convert

    local_base : str
        base path on local system

    remote_base : str
        corresponding base path on remote system

    """
    return re.sub("^" + local_base, remote_base, local)


def download_file(url, filename):
    """
    Download a file at a url and put it into a local location

    Parameters
    ----------

    url : str
        URL of file to download

    filename : str
        local path to put file in
    """
    if(os.path.isfile(filename) is True):
        return filename

    filedir = os.path.dirname(filename)
    if(os.path.isdir(filedir) is False):
        os.makedirs(filedir)

    response = requests.get(url)

    with open(filename, 'wb') as fd:
        for chunk in response.iter_content(chunk_size=128):
            fd.write(chunk)

    return filename


class Path(base_path):
    """Class for supporting construction of NASA-Sloan Atlas paths.
    Typical usage relies on the get() method.
    """

    def __init__(self, pathfile=None):
        if(pathfile is None):
            pathfile = os.path.join(os.getenv('DIMAGE_DIR'),
                                    'data', 'dimage_paths.ini')
        super(Path, self).__init__(pathfile)
        self.nsaid_to_iauname_dict = None
        self.iauname_to_nsaid_dict = None
        self.remote_base = 'http://data.sdss.org'
        self.local_base = '/data'
        self._remote = False

    def _reset(self):
        self.nsaid_to_iauname_dict = None
        self.iauname_to_nsaid_dict = None

    def _nsaid_init(self, **kwargs):
        """Initializes translation table from NSAID to IAUNAME.
        """
        atlas = fitsio.read(self.get('atlas', version=kwargs['version']))
        iauname = atlas['IAUNAME']
        nsaid = range(len(iauname))
        self.nsaid_to_iauname_dict = dict(zip(nsaid, iauname))
        self.iauname_to_nsaid_dict = dict(zip(iauname, nsaid))

    def remote(self, remote_base=None, local_base=None,
               username=None, password=None):
        """
        Configures remote access for NASA-Sloan Atlas.

        Parameters
        ----------
        remote_base : str
            base URL path for remote repository
        local_base : str
            base file path for local repository
        username : str
            user name for remote repository
        password : str
            password for local repository
        """
        if(remote_base is not None):
            self.remote_base = remote_base
        if(local_base is not None):
            self.local_base = local_base
        self._remote = True
        requests.get(self.remote_base, auth=(username, password))

    def nsaid_to_iauname(self, nsaid, **kwargs):
        """
        Returns IAUNAME given NSAID

        Parameters
        ----------
        nsaid : int
          NSAID to infer IAUNAME from

        Returns
        -------
        iauname : str
          IAUNAME to infer NSAID from

        Notes
        -----
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

        Parameters
        ----------
        iauname : str
          IAUNAME to infer NSAID from

        Returns
        -------
        nsaid : np.int32
            NSAID index

        Notes
        -----
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

        Parameters
        ----------
        nsaid : int
          NSAID

        Returns
        -------
        pid : int
          parent IDs of processed objects in image
        """
        pcat = fitsio.read(self.get('pcat', nsaid=nsaid, **kwargs))
        # Infers from where CRA isn't zero
        indx = np.nonzero(pcat['CRA'])
        return indx

    def nsaid_to_aid(self, nsaid, pid, **kwargs):
        """
        Returns AID values for NSAID/PID

        Parameters
        ----------
        nsaid : int
          NSAID
        pid : int
          parent ID

        Returns
        -------
        aid : int
          aid of detected object
        """
        measure = fitsio.read(self.get('measure', pid=pid, nsaid=nsaid,
                                       **kwargs))
        # Infers from where measurements exist
        aid = measure['AID']
        return aid

    def local(self):
        """Configures local access for NASA-Sloan Atlas
        """
        self._remote = False

    def v1(self, filetype, **kwargs):
        """Path utility to interpret %v1 directive
        """
        try:
            return version_to_topdir(kwargs['version'])
        except KeyError:
            return None

    def v2(self, filetype, **kwargs):
        """Path utility to interpret %v2 directive
        """
        try:
            return version_to_detectdir(kwargs['version'])
        except KeyError:
            return None

    def iauname(self, filetype, **kwargs):
        """Path utility to interpret %iauname directive
        """
        if 'iauname' in kwargs:  # Set IAUNAME if given
            return kwargs['iauname']
        else:  # Use NSAID/RADEC to deduce IAUNAME if need be
            if 'ra' in kwargs and 'dec' in kwargs:
                return radec_to_iauname(**kwargs)
            if 'nsaid' in kwargs:
                return self.nsaid_to_iauname(**kwargs)

    def subdir(self, filetype, **kwargs):
        """Path utility to interpret %subdir directive
        """
        iauname = self.iauname(filetype, **kwargs)
        return iauname_to_subdir(iauname)

    def pid(self, filetype, **kwargs):
        """Path utility to interpret %pid directive
        """
        iauname = self.iauname(filetype, **kwargs)
        kwargs['nsaid'] = self.iauname_to_nsaid(iauname)
        return str(self.nsaid_to_pid(**kwargs)[0][0])

    def aid(self, filetype, **kwargs):
        """Path utility to interpret %aid directive
        """
        iauname = self.iauname(filetype, **kwargs)
        kwargs['nsaid'] = self.iauname_to_nsaid(iauname)
        kwargs['pid'] = self.nsaid_to_pid(**kwargs)[0][0]
        return str(self.nsaid_to_aid(**kwargs)[0])

    def url(self, filetype, **kwargs):
        """Constructs URL based on file name

        Parameters
        ----------
        filetype : str
            type of file

        keyword arguments :
            keywords to fully specify URL

        Notes
        -----
        Path templates are defined in $DIMAGE_DIR/data/dimage_paths.ini
        """
        filename = self.full(filetype, **kwargs)
        return(local_to_url(filename, local_base=self.local_base,
                            remote_base=self.remote_base))

    def get(self, filetype, **kwargs):
        """Returns file name, downloading if remote access configured.

        Parameters
        ----------
        filetype : str
            type of file

        keyword arguments :
            keywords to fully specify path

        Notes
        -----
        Path templates are defined in $DIMAGE_DIR/data/dimage_paths.ini
        """
        filename = self.full(filetype, **kwargs)
        if(self._remote is True):
            download_file(self.url(filetype, **kwargs), filename)
        return(filename)
