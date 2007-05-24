;+
; NAME:
;   dexplore
; PURPOSE:
;   interactive explorer of dimage results
; CALLING SEQUENCE:
;   dexplore [, base ]
; OPTIONAL INPUTS:
;   base - base name for output (otherwise uses current dir name)
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dexplore, base, lsb=lsb

if(NOT keyword_set(base)) then begin
    spawn, 'pwd', cwd
    words=strsplit(cwd[0], '/',/extr)
    base=words[n_elements(words)-1]
endif

images=base+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'

dexplore_widget, base, images, lsb=lsb

end
;------------------------------------------------------------------------------
