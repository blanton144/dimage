;+
; NAME:
;   atlas_zcat
; PURPOSE:
;   builds the ZCAT catalog for atlas
; CALLING SEQUENCE:
;   atlas_zcat
; REVISION HISTORY:
;   18-Nov-2003  Written by Mike Blanton, NYU
;   15-Aug-2010  Fixed for atlas, MRB NYU
;-
;------------------------------------------------------------------------------
pro atlas_zcat, version=version

rootdir=atlas_rootdir(version=version)
if(file_test(rootdir, /dir) eq 0) then $
   message, 'No root directory for '+version+': '+rootdir
info= atlas_version_info(version)

spawn, /nosh, ['mkdir', '-p', rootdir+'/catalogs/zcat']
spawn, ['cp', getenv('DIMAGE_DIR')+ $
        '/data/atlas/catalogs/zcat-velocity.dat', $
        rootdir+'/catalogs/zcay'], /nosh

zcat2fits, version=version

zcat=mrdfits(rootdir+'/catalogs/zcat/zcat-velocity.fits',1)

ikeep= where(zcat.z lt info.zmax and $
             zcat.z gt -0.05 and $
             zcat.z ne 0. and $
             strmatch(zcat.comments, 'SDSS*') eq 0)
zcat=zcat[ikeep]

mwrfits, zcat, rootdir+'/catalogs/zcat_atlas.fits', /create

end
