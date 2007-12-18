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
                     _EXTRA=extra_for_gz_mrdfits 

if(n_elements(ext) eq 0) then ext=0

str=mrdfits(file, ext, hdr, status=status, $
            _EXTRA=extra_for_gz_mrdfits)
if(status ne 0) then begin
    splog, 'Trying .gz extension ...'
    str=mrdfits(file+'.gz', ext, hdr, status=status, $
                _EXTRA=extra_for_gz_mrdfits)
endif
if(status ne 0) then begin
    splog, 'Trying .Z extension ...'
    str=mrdfits(file+'.Z', ext, hdr, status=status, $
                _EXTRA=extra_for_gz_mrdfits)
endif
if(status ne 0) then begin
    splog, 'Trying .z extension ...'
    str=mrdfits(file+'.z', ext, hdr, status=status, $
                _EXTRA=extra_for_gz_mrdfits)
endif
if(status ne 0) then begin
    splog, 'Failed to read file '+file
endif

return, str

end
;------------------------------------------------------------------------------
