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
atlas_all_detect, version=version
atlas_all_derived, version=version

end
