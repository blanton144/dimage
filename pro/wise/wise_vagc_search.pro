;+
; NAME: 
;   wise_atlas_search
; PURPOSE: 
;   Create upload table to match VAGC to WISE source catalog
; CALLING SEQUENCE: 
;   wise_vagc_search
; REVISION HISTORY:
;   22-Apr-2011 MRB NYU
;-
pro wise_vagc_search

vagc= mrdfits(getenv('VAGC_REDUX')+'/object_radec.fits',1)

euler, vagc.ra, vagc.dec, elon, elat, 3
iin= where((elon gt 27.8 and elon lt 133.4) OR $
           (elon gt 201.9 and elon lt 309.6), nin)

openw, unit, 'wise_vagc_search.txt', /get_lun
printf, unit, 'id,ra,dec'
for i=0L, nin-1L do begin
    printf, unit, strtrim(string(iin[i]),2)+','+ $
      strtrim(string(f='(f40.8)', vagc[iin[i]].ra),2)+','+ $
      strtrim(string(f='(f40.8)', vagc[iin[i]].dec),2)
endfor
free_lun, unit

END 
