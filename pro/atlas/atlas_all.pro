;+
; NAME:
;   atlas_all
; PURPOSE:
;   Wrapper script for producing NSA atlas
; CALLING SEQUENCE:
;   atlas_all, version=
; REVISION HISTORY:
;   31-Mar-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_all, version=version

rootdir=atlas_rootdir(version=version)
if(file_test(rootdir, /dir) eq 0) then $
   message, 'No root directory for '+version+': '+rootdir

atlas_all_catalogs, version=version

;; need PHOTO_SKY set
atlas_dimages

;; need galex-orig there
galex_image_combine

;; needs to get directories right
;; make top-lvel detect directory
atlas_detect_dirs

detect_atlas_all

;; make measure directory
atlas_gather, version= version
;; make derived directory
atlas_duplicates, version= version
;; make sure sdssline_atlas is in place
finalz_atlas, version= version
velmod_atlas, version= version
atlas_startrim, version= version
atlas_kcorrect, version= version
;; make sure sdssline_atlas is in place
atlas_nsafile, version= version

;; make sure sdssline_atlas is in place
atlas_nsafile

end
