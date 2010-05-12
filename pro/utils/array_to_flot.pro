;+
; NAME:
;   array_to_flot
; PURPOSE:
;   create a flot-style data command for an array pair
; CALLING SEQUENCE:
;   array_to_flot, filename, xx, yy
; REVISION HISTORY:
;   1-May-2010  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro array_to_flot, filename, xx, yy

openw, unit,filename, /get_lun

printf, unit, '{'
printf, unit, 'data: ['
for i=0L, n_elements(xx)-1L do begin
    printf, unit, '['+strtrim(string(xx[i]),2)+','+ $
            strtrim(string(yy[i]),2)+'], '
endfor
printf, unit, ']'
printf, unit, '}'

free_lun, unit

end
;------------------------------------------------------------------------------
