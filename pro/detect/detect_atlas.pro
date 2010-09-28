;+
; NAME:
;   detect_atlas
; PURPOSE:
;   detect objects in NASA-Sloan Atlas images
; CALLING SEQUENCE:
;   detect_atlas
; OPTIONAL KEYWORDS:
;   /galex - assume ugrizNF (N and F from GALEX)
;   /noclobber - do not overwrite previously created files
;   /noparentclobber - do not overwrite previously PARENT files
; COMMENTS:
;   Assumes input file names of the form:
;      [base]-[ugriz].fits.gz
;    where [base] is the current directory name. If /galex is set, 
;    includes -nd and -fd images from GALEX too.
;   Assumes that the images are APPROXIMATELY overlapping
;     (within a pixel or two) at least
;   Assumes a sky-subtracted image in HDU 0
;   Works better if ivars supplied in HDU 1
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro detect_atlas, galex=galex, noclobber=noclobber
  
dparents_atlas, galex=galex, noclobber=noclobber

dpsf_atlas, galex=galex, noclobber=noclobber

dstargal_atlas, /plot
return

dchildren_atlas, galex=galex, noclobber=noclobber

end
;------------------------------------------------------------------------------
