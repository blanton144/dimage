;+
; NAME:
;   dimage_hdr
; PURPOSE:
;   return header with dimage version
; CALLING SEQUENCE:
;   hdr=dimage_hdr()
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dimage_hdr

hdr=['']
sxaddpar, hdr, 'DVERSION', dimage_version(), 'dimage version'

return, hdr

end
;------------------------------------------------------------------------------
