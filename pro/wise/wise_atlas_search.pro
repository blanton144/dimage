;+
; NAME: 
;   wise_atlas_search
; PURPOSE: 
;   Create upload table to match atlas to WISE source catalog
; CALLING SEQUENCE: 
;   wise_atlas_search
; REVISION HISTORY:
;   14-Apr-2011 MRB NYU
;-
pro wise_atlas_search, version=version

rootdir=atlas_rootdir(version=version)

atlas= mrdfits(rootdir+'/catalogs/atlas.fits',1)
measure= mrdfits(rootdir+'/catalogs/atlas_measure.fits',1)

euler, measure.racen, measure.deccen, elon, elat, 3
iin= where((elon gt 27.8 and elon lt 133.4) OR $
           (elon gt 201.9 and elon lt 309.6), nin)

openw, unit, 'wise_atlas_search.txt', /get_lun
printf, unit, 'id,ra,dec'
for i=0L, nin-1L do begin
    printf, unit, strtrim(string(iin[i]),2)+','+ $
      strtrim(string(f='(f40.8)', measure[iin[i]].racen),2)+','+ $
      strtrim(string(f='(f40.8)', measure[iin[i]].deccen),2)
endfor
free_lun, unit

END 
