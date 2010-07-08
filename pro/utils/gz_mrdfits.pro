;+
; NAME:
;   gz_mrdfits
; PURPOSE:
;   mrdfits, but if it fails, try reading in .gz version
; CALLING SEQUENCE:
;   str= gz_mrdfits([params for mrdfits])
; REVISION HISTORY:
;   27-Sep-2006  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function gz_mrdfits, file, ext, hdr, status=status, $
                     silent=silent, _EXTRA=extra_for_gz_mrdfits 

if(n_elements(ext) eq 0) then ext=0

exts=['', '.gz', '.Z', '.z']

for i=0L, n_elements(exts)-1L do begin
    tryfile=file+exts[i]
    fexist= file_test(tryfile)
    if(fexist gt 0) then begin
        if(keyword_set(silent) eq 0 AND i gt 0) then $
          splog, 'Trying '+exts[i]+' extension ...'
        str=mrdfits(tryfile, ext, hdr, status=status, silent=silent, $
                    _EXTRA=extra_for_gz_mrdfits)
        if(status eq 0) then $
          return, str
    endif
endfor

splog, 'Failed to read file '+file
return, 0

end
;------------------------------------------------------------------------------
