;+
; NAME:
;   datv
; PURPOSE:
;   wrapper on atv to show images from dimage pipeline
; CALLING SEQUENCE:
;   datv, base [, band=, /parent ]
; INPUTS:
;   base - base name for output
; OPTIONAL KEYWORDS:
;   /parent - show parent image
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro datv, base, band=band, parent=parent, pid=pid, pimage=pimage, $
          atlas=atlas, aid=aid, block=block

if(NOT keyword_set(band)) then band=0

if(keyword_set(pimage)) then begin
    imfile=base+'-pimage.fits'
    image=mrdfits(imfile, 0L, hdr)
    atv, image, head=hdr, block=block
    return 
endif

if(keyword_set(parent)) then begin
    imfile='parents/'+base+'-parent-'+strtrim(string(pid),2)+'.fits'
    image=mrdfits(imfile, band*2L, hdr)
    atv, image, head=hdr, block=block
    return 
endif


if(keyword_set(atlas)) then begin
    imfile='atlases/'+strtrim(string(pid),2)+'/'+base+'-'+ $
      strtrim(string(pid),2)+'-atlas-'+strtrim(string(aid),2)+'.fits'
    if(file_test(imfile)) then begin
        image=mrdfits(imfile, band, hdr)
        atv, image, head=hdr, block=block
    endif
    return 
endif

end
;------------------------------------------------------------------------------
