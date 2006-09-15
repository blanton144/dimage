;+
; NAME:
;   dfakegal
; PURPOSE:
;   get parameters associated with sersic settings
; CALLING SEQUENCE:
;   dfakegal, flux, n, r50, amp=amp, r0=r0
; INPUTS:
;   flux - flux
;   n - Sersic index
;   r50 - half-light radius
; OPTIONAL INPUTS:
; KEYWORDS:
; OUTPUTS:
;   amp - amplitude 
;   r0 - radius
; OPTIONAL OUTPUTS:
; OPTIONAL INPUTS/OUTPUTS:
; COMMENTS:
;   I(r)= amp*exp(-(r/r0)^(1/n))
; DEPENDENCIES:
; BUGS:
; REVISION HISTORY:
;   2003-09-21  Written MRB (NYU)
;-
function dfakegal, sersicn=sersicn, r50=r50, flux=flux, nx=nx, ny=ny, $
                   xcen=xcen, ycen=ycen, ba=ba, phi0=phi0, $
                   spars=sersic

if(n_elements(sersicn) eq 0) then sersicn=1.
if(n_elements(r50) eq 0) then r50=1.
if(n_elements(flux) eq 0) then flux=1.
if(n_elements(nx) eq 0) then nx=20
if(n_elements(ny) eq 0) then ny=20
if(n_elements(xcen) eq 0) then xcen=nx/2L
if(n_elements(ycen) eq 0) then ycen=ny/2L
if(n_elements(ba) eq 0) then ba=1.
if(n_elements(phi0) eq 0) then phi0=0.

if(n_elements(sersic) gt 0) then begin
    sersicn=sersic.sersicn
    r50=sersic.sersicr50
    flux=sersic.sersicflux
    xcen=sersic.xcen
    ycen=sersic.ycen
    ba=sersic.axisratio
    phi0=sersic.orientation
endif

image=fltarr(nx,ny)
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')
retval=call_external(soname, 'idl_dfake', float(image), long(nx), $
                     long(ny), float(xcen), float(ycen), float(sersicn), $
                     float(r50),float(ba),float(phi0))
image=image*flux

return, image
end
