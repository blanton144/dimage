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
pro detect_atlas, galex=galex, noclobber=noclobber, nsigma=nsigma, glim=glim, $
                  gsmooth=gsmooth, twomass=twomass

;; default to use base name same as directory name
spawn, 'pwd', cwd
base=(file_basename(cwd))[0]

if(keyword_set(noclobber) ne 0) then begin
   dreadcen, acat=acat
   if(n_tags(acat) gt 0) then begin
      splog, 'Already found child catalog, skipping.'
      return
   endif
endif

imfiles=base+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
if (keyword_set(galex) gt 0) then begin
    imfiles=[imfiles, base+'-'+['nd', 'fd']+'.fits.gz']
endif 
if (keyword_set(twomass) gt 0) then begin
    imfiles=[imfiles, base+'-'+['J', 'H', 'K']+'.fits.gz']
endif 
allthere=1
for i=0L, n_elements(imfiles)-1L do $
   if(file_test(imfiles[i]) eq 0) then $
      allthere=0
if(allthere eq 0) then begin
   splog, 'No image files for '+base
   return
endif

dparents_atlas, galex=galex, twomass=twomass, noclobber=noclobber

dpsf_atlas, noclobber=noclobber

dstargal_atlas, nsigma=nsigma, glim=glim, gsmooth=gsmooth, noclobber=noclobber

dchildren_atlas, noclobber=noclobber

heap_gc

end
;------------------------------------------------------------------------------
