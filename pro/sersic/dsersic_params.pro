;+
; NAME:
;   dsersic_params
; PURPOSE:
;   given flux, r50, n  
; CALLING SEQUENCE:
;   dsersic_params, flux, n, r50, amp=, r0=
; INPUTS:
;   flux - flux
;   n - Sersic index
;   r50 - half-light radius
; OUTPUTS:
;   amp - amplitude 
;   r0 - radius
; COMMENTS:
;   I(r)= amp*exp(-(r/r0)^(1/n))
; REVISION HISTORY:
;   2003-09-21  Written MRB (NYU)
;-
pro dsersic_params, flux, n, r50, amp=amp, r0=r0

soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

amp=0.
r0=0.
retval=call_external(soname, 'idl_dsersic_params', float(flux), float(n), $
                     float(r50), float(amp), float(r0))
end
