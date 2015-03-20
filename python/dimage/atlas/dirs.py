import dimage
import astropy.coordinates  as coordinates
import os

def default_version():
    return 'v1_0_0'
    
def iauname(ra, dec):
    precision=2
    ra_angle= coordinates.Angle(ra, unit='degree')
    rastr= ra_angle.to_string(unit='hour', sep='', precision=precision,
                              pad=True)
    dec_angle= coordinates.Angle(dec, unit='degree')
    decstr= dec_angle.to_string(unit='degree', sep='', precision=precision-1,
                                pad=True, alwayssign=True)
    return 'J'+rastr+decstr

def rootdir(version):
    vN= (version.split('_'))[0]
    return os.path.join(os.getenv('ATLAS_DATA'), vN)
    
def subdir(ra, dec, subname=None, version=None, rootdir=None):
    if version is None:
        version= dimage.atlas.default_version()
    if rootdir is None:
        rootdir= dimage.atlas.rootdir(version)
    if subname is None:
        subname= version.split('_')[0]+'_'+version.split('_')[1]
    ihr= "%02d" % int(ra/15.)
    idec= "%02d" % (int(abs(dec)/2.)*2)
    if dec<0.:
        dsign='m'
    else:
        dsign='p'
    prefix= dimage.atlas.iauname(ra, dec)
    outdir= os.path.join(rootdir, 'detect',
                         subname, ihr+'h', dsign+idec, prefix)
    return outdir
