;+
; NAME:
;   dcombine_multi
; PURPOSE:
;   combine atlas catalogs into the big catalog of good galaxy children
; CALLING SEQUENCE:
;   dcombine_multi
; INPUTS:
;   base - base name for output
;   hdr - header for astrometry
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dcombine_multi, base, hand=hand

hdr=headfits(base+'-pimage.fits',ext=0)
pcat=mrdfits(base+'-pcat.fits',1)

uid=0L
ucat0={uid:0L, $
       pid:0L, $
       aid:0L, $
       x:0., $
       y:0., $
       ra:0., $
       dec:0., $
       xst:0L, $
       yst:0L, $
       xnd:0L, $
       ynd:0L, $
       hand:0L}
for pid=0L, n_elements(pcat)-1L do begin
    chand=0
    struct_assign, pcat[pid], ucat0
    afile='atlases/'+strtrim(string(pid),2)+ $
      '/'+base+'-'+strtrim(string(pid),2)+ $
      '-acat.fits'
    if(keyword_set(hand)) then begin
        hfile='hand/'+strtrim(string(pid),2)+ $
          '/'+base+'-'+strtrim(string(pid),2)+ $
          '-acat.fits'
        if(file_test(hfile)) then begin
            afile=hfile
            chand=1
        endif
    endif
    if(file_test(afile)) then begin
        acat=mrdfits(afile,1, /silent)
        if(n_tags(acat) gt 0) then begin
            for aid=0L, n_elements(acat)-1L do begin
                if(acat[aid].good) then begin
                    ucat0.uid=uid
                    ucat0.aid=aid
                    ucat0.pid=pid
                    ucat0.hand=chand
                    ucat0.x=acat[aid].xcen+pcat[pid].xst
                    ucat0.y=acat[aid].ycen+pcat[pid].yst
                    if(n_tags(ucat) eq 0) then $
                      ucat=ucat0 $
                    else $
                      ucat=[ucat, ucat0]
                    uid=uid+1L
                endif
            endfor
        endif
    endif
endfor

if(n_tags(ucat) gt 0) then begin
    xyad, hdr, ucat.x, ucat.y, ra, dec
    ucat.ra=ra
    ucat.dec=dec
    
    mwrfits, ucat, base+'-ucat.fits', /create
endif

end
;------------------------------------------------------------------------------
