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
atlas_gather
atlas_duplicates
velmod_atlas
atlas_kcorrect

end
