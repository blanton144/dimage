;+
; NAME:
;   read_ned_compact
; PURPOSE:
;   Read a NED compact output file into a structure
; CALLING SEQUENCE:
;   ned= read_ned_compact(filename)
; INPUTS:
;   filename - NED file to read in
; OUTPUTS:
;   ned - structure
; REVISION HISTORY:
;   2-May-2008  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function read_ned_compact, filename

openr, unit, filename, /get_lun

linestr=''
while(strtrim(linestr,2) ne 'PARAMETERS') do begin
    readf,unit,linestr
endwhile

readf, unit, linestr
words=strsplit(linestr, /extr)
nobj= long(words[0])
str1= {type:' ', name1:' ', name2:' ', ra:0.D, dec:0.D, radecstr:' ', vel:0., $
       ref:0L, fld1:' ', fld2:0., fld3:0., fld4:0., vel_unc:0L, $
       pht:0L }
str= replicate(str1, nobj)

readf, unit, linestr
readf, unit, linestr
for i=0L, nobj-1L do begin
    readf, unit, linestr
    str[i].type= strtrim(strmid(linestr, 0L, 6L),2)
    str[i].name1= strmid(linestr, 7L, 16L)
    str[i].radecstr= strmid(linestr, 24L, 22L)
    str[i].vel= float(strmid(linestr, 47L, 8L))
    str[i].ref= long(strmid(linestr, 56L, 3L))
    str[i].fld1=strmid(linestr, 60L, 20L)

    readf, unit, linestr
    str[i].name2= strmid(linestr, 7L, 16L)
    vel_unc_str= strmid(linestr, 47L, 8L)
    if(strtrim(vel_unc_str,2) eq '') then vel_unc_str='0.'
    str[i].vel_unc= float(vel_unc_str)
    str[i].pht= long(strmid(linestr, 56L, 3L))
    fld2str=strmid(linestr, 60L, 7L)
    if(strtrim(fld2str,2) eq '') then fld2str='0.'
    if(strtrim(fld2str,2) eq '/?') then fld2str='0.'
    str[i].fld2= float(fld2str)
    fld3str= strmid(linestr, 68L, 6L)
    if(strtrim(fld3str,2) eq '') then fld3str='0.'
    str[i].fld3= float(fld3str)
    fld4str= strmid(linestr, 75L, 6L)
    if(strtrim(fld4str,2) eq '') then fld4str='0.'
    if(strtrim(fld4str,2) eq '/?') then fld4str='0.'
    str[i].fld4= float(fld4str)

    string2radec, strmid(str[i].radecstr,0L, 2L), $
                  strmid(str[i].radecstr,3L, 2L), $
                  strmid(str[i].radecstr,6L, 4L), $
                  strmid(str[i].radecstr,12L, 3L), $
                  strmid(str[i].radecstr,16L, 2L), $
                  strmid(str[i].radecstr,19L, 2L), $
                  ra, dec
    str[i].ra=ra
    str[i].dec=dec
endfor

free_lun, unit

return, str

end
;------------------------------------------------------------------------------
