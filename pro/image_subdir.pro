;+
; NAME:
;   image_subdir
; PURPOSE:
;   construct a subdirectory name for an image given its ra and dec
; CALLING SEQUENCE:
;   subdir= image_subdir(ra, dec, prefix=)
; INPUTS:
;   ra, dec - coordinates (deg)
; OUTPUTS:
;   subdir - subdirectory name, of form:
;             HHh/[pm]DD/[iau_name]
;   prefix - [iau_name] 
; COMMENTS:
;   The directories are broken up into hours in the RA direction
;   and 2-degree chunks in the Dec direction.  E.g.:
;       IDL> print,image_subdir(0.,27.)
;       /global/data/dimages/00h/p26/J000000.00+270000.0
;       IDL> print,image_subdir(0.,-6.)
;       /global/data/dimages/00h/m06/J000000.00-060000.0
;       IDL> print,image_subdir(0.,1.)
;       /global/data/dimages/00h/p00/J000000.00+010000.0
; REVISION HISTORY:
;   23-June-2007  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function image_subdir, ra, dec, prefix=prefix

ihr=long(ra/15.)
idec=long(abs(dec)/2.)*2.
dsign='p'
if(dec lt 0.) then dsign='m'
outdir=getenv('DATA')+'/dimages/'+string(ihr,f='(i2.2)')+'h'
outdir=outdir+'/'+dsign+strtrim(string(idec, f='(i2.2)'),2)
prefix=(strtrim(hogg_iau_name(ra, dec,''),2))[0]
outdir=outdir+'/'+prefix

return, outdir

end
