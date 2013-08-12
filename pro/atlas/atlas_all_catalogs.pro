;+
; NAME:
;   atlas_all_catalogs
; PURPOSE:
;   Create catalogs for NSA
; CALLING SEQUENCE:
;   atlas_all_catalogs, version=
; COMMENTS:
;   This code does *not* create ned_atlas.fits, which is more
;     complicated due to querying NED, and just copies it from 
;     the dimage product.
; REVISION HISTORY:
;   31-Mar-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_all_catalogs, version=version

rootdir=atlas_rootdir(version=version)
if(file_test(rootdir, /dir) eq 0) then $
   message, 'No root directory for '+version+': '+rootdir

;; SDSS
sdss_speclist, version=version
atlas_sdss, version=version

;; NED
spawn, ['cp', getenv('DIMAGE_DIR')+'/data/atlas/catalogs/ned_atlas.fits', $
        rootdir+'/catalogs'], /nosh

;; 6dFGRS
atlas_sixdf, version=version

;; 2dFGRS
atlas_twodf, version=version

;; ALFALFA
atlas_alfalfa, version=version

;; ZCAT
atlas_zcat, version=version

combine_atlas, version=version
iminfo_atlas, version=version
final_atlas, version=version

end
