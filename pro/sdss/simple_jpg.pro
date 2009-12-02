;+
; NAME:
;   simple_jpg
; CALLING SEQUENCE:
;   simple_jpg
; REVISION HISTORY:
;   21-Jun-2009  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro simple_jpg, rebin=rebin

if(NOT keyword_set(base)) then begin
    spawn, 'pwd', cwd
    words=strsplit(cwd[0], '/',/extr)
    base=words[n_elements(words)-1]
endif

if(NOT keyword_set(scales)) then scales=[4., 5., 6.]
if(NOT keyword_set(satvalue)) then satvalue=30.
if(NOT keyword_set(nonlinearity)) then nonlinearity=3.
djs_rgb_make, base+'-i.fits.gz', $
  base+'-r.fits.gz', $
  base+'-g.fits.gz', $
  name=base+'.jpg', $
  scales=scales, $
  nonlinearity=nonlinearity, satvalue=satvalue, $
  quality=100., rebin=rebin

end
;------------------------------------------------------------------------------
