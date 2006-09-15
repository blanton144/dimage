;+
; NAME:
;   astromxy
; PURPOSE:
;   get basic X and Y for brightish sources away from edge of an image
; CALLING SEQUENCE:
;   astromxy, image, x, y, flux
; INPUTS:
;   image - [nx, ny] input image
; OUTPUTS:
;   x, y - [N] central positions
;   flux - [N] central fluxes
; REVISION HISTORY:
;   1-Mar-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro astromxy, image, x, y, flux, proc=proc

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

if(NOT keyword_set(proc)) then begin
    invvar=dinvvar(image, hdr=hdr, satur=satur)
    sigma=1./sqrt(median(invvar))
endif else begin
    sigma=dsigma(image)
    invvar=fltarr(nx, ny)+1./sigma^2
endelse
msmooth=dmedsmooth(image, invvar, box=50L)
simage=image-msmooth
dobjects, simage, invvar, object=oimage, smooth=smooth, plim=12.
dallpeaks, simage, oimage, xc=x, yc=y, sigma=sigma
dpsfflux, simage, x, y, gauss=2., flux=flux

end
;------------------------------------------------------------------------------
