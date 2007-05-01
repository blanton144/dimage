;+
; NAME:
;   dfakegal
; PURPOSE:
;   get parameters associated with sersic settings
; CALLING SEQUENCE:
;   im= dfakegal([ sersicn=, r50=, flux=, phi0=, ba=, /simple, $
;                  nx=, ny=, xcen=, ycen=, sersic= ])
; INPUTS:
;   flux - flux (default 1.)
;   sersicn - Sersic index (default 1.)
;   r50 - half-light radius (default 1.)
;   phi0 - position angle (deg counterclockwise from up, default 0.)
;   ba - axis ratio (b/a, default 1.)
;   nx, ny - size of output image (defuat 
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
                   sersic=sersic, simple=simple

if(n_elements(sersicn) eq 0) then sersicn=1.
if(n_elements(r50) eq 0) then r50=1.
if(n_elements(flux) eq 0) then flux=1.
if(n_elements(nx) eq 0) then nx=20
if(n_elements(ny) eq 0) then ny=20
if(n_elements(xcen) eq 0) then xcen=nx/2L
if(n_elements(ycen) eq 0) then ycen=ny/2L
if(n_elements(ba) eq 0) then ba=1.
if(n_elements(phi0) eq 0) then phi0=0.
if(n_elements(simple) eq 0) then simple=0L

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
                     float(r50),float(ba),float(phi0), long(simple))
image=image*flux

return, image
end
