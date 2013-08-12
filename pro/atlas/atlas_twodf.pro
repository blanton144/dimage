;+
; NAME:
;   atlas_twodf
; PURPOSE:
;   Convert the 2dF file into an atlas-appropriate file
; CALLING SEQUENCE:
;   twodf_atlas
; REVISION HISTORY:
;   31-Jul-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_twodf, version=version

rootdir=atlas_rootdir(version=version)
if(file_test(rootdir, /dir) eq 0) then $
   message, 'No root directory for '+version+': '+rootdir
info= atlas_version_info(version)

spawn, /nosh, ['mkdir', '-p', rootdir+'/catalogs/twodf']
spawn, ['cp', getenv('DIMAGE_DIR')+ $
        '/data/atlas/catalogs/twodf_catalog.fits.gz', $
        rootdir+'/catalogs/twodf'], /nosh

two= mrdfits(rootdir+'/catalogs/twodf/twodf_catalog.fits.gz', 1)

ikeep= where(two.z_helio lt info.zmax)
two=two[ikeep]

mwrfits, two, rootdir+'/catalogs/twodf_atlas.fits', /create

end

