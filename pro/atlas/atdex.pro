;+
; NAME:
;   atdex
; PURPOSE:
;   dexplore an atlas
; CALLING SEQUENCE:
;   sdss_sfit, plate, fiberid, mjd [, sfit= ]
; REVISION HISTORY:
;   3-Aug-2007  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atdex, indx, name=name, subname=subname, sample=sample, twomass=twomass

if(n_elements(name) gt 0) then $
  nat= n_elements(name) $
else $
  nat=n_elements(indx)

for i=0L, nat-1L do begin
    if(n_elements(name) eq 0) then begin
        splog, indx[i]
        atcd, indx[i], subname=subname, sample=sample
    endif else begin
        atcd, name=name[i], subname=subname, sample=sample
    endelse

    dexplore, /cen, twomass=twomass
endfor

end
