;+
; NAME:
;   atlas_alfalfa
; PURPOSE:
;   builds the ALFALFA catalog for atlas
; CALLING SEQUENCE:
;   atlas_alfalfa
; REVISION HISTORY:
;   15-Aug-2010  Fixed for atlas, MRB NYU
;-
;------------------------------------------------------------------------------
pro atlas_alfalfa, version=version

rootdir= atlas_rootdir(version=version)
if(file_test(rootdir, /dir) eq 0) then $
   message, 'No root directory for '+version+': '+rootdir
info= atlas_version_info(version)

spawn, /nosh, ['mkdir', '-p', rootdir+'/catalogs/alfalfa']
spawn, ['cp', getenv('DIMAGE_DIR')+ $
        '/data/atlas/catalogs/alfalfa3.txt', $
        rootdir+'/catalogs/alfalfa'], /nosh

alfalfa2fits, version=version

alfalfa=mrdfits(rootdir+'/catalogs/alfalfa/alfalfa3.fits',1)

ikeep= where(alfalfa.cz/299792. lt info.zmax)
alfalfa=alfalfa[ikeep]

mwrfits, alfalfa, rootdir+'/catalogs/alfalfa_atlas.fits', $
         /create

end
