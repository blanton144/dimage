;+
; NAME:
;   read_ned_galaxies
; PURPOSE:
;   Read a NED compact output file into a structure and pick out galaxies
; CALLING SEQUENCE:
;   ned= read_ned_galaxies(filename)
; INPUTS:
;   filename - NED file to read in
; OUTPUTS:
;   ned - structure
; REVISION HISTORY:
;   2-May-2008  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function read_ned_galaxies, filename

ned=read_ned_compact(filename)

igal= where(strtrim(ned.type,2) eq 'G' AND $
            strmatch(ned.name1, 'COMBO-17*') eq 0, ngal)
if(ngal eq 0) then return, 0

ned=ned[igal]
gal1= {type:' ', name1:' ', name2:' ', ra:0.D, dec:0.D, radecstr:' ', vel:0., $
       ref:0L, morph:' ', mag:0., major:0., minor:0., vel_unc:0L, $
       pht:0L }
gal=replicate(gal1, ngal)
struct_assign, ned, gal

gal.morph= ned.fld1 
gal.mag= ned.fld2 
gal.major= ned.fld3 
gal.minor= ned.fld4 

return, gal

end
;------------------------------------------------------------------------------
