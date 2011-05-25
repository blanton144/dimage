;+
; NAME:
;   atlas_rootdir
; PURPOSE:
;   return root name directory of atlas
; CALLING SEQUENCE:
;   rootdir= atlas_rootdir()
; REVISION HISTORY:
;   3-Aug-2007  MRB, NYU
;-
;------------------------------------------------------------------------------
function atlas_rootdir, sample=sample

  rootdir='/mount/hercules5/sdss/atlas/v0'
  if(keyword_set(sample)) then $
     rootdir='/mount/hercules5/sdss/atlas/sample'
  
  return, rootdir
  
end
