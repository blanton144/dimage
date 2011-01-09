;+
; NAME:
;   simplexy
; PURPOSE:
;   get basic X and Y for brightish sources away from edge of an image
; CALLING SEQUENCE:
;   simplexy, image, x, y, flux
; INPUTS:
;   image - [nx, ny] input image
; OUTPUTS:
;   x, y - [N] central positions
;   flux - [N] central fluxes
; REVISION HISTORY:
;   1-Mar-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro simplexy, image, x, y, flux, proc=proc

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

if(NOT keyword_set(dpsf)) then dpsf=1.
if(NOT keyword_set(plim)) then plim=8. 
if(NOT keyword_set(dlim)) then dlim=1. 
if(NOT keyword_set(saddle)) then saddle=3. 
if(NOT keyword_set(maxper)) then maxper=1000L
if(NOT keyword_set(maxnpeaks)) then maxnpeaks=100000L

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

npeaks=0L
x=fltarr(maxnpeaks)
y=fltarr(maxnpeaks)
flux=fltarr(maxnpeaks)
sigma=0.
retval=call_external(soname, 'idl_simplexy', $
                     float(image), $
                     long(nx), long(ny), $
                     float(dpsf), $
                     float(plim), $
                     float(dlim), $
                     float(saddle), $
                     long(maxper), $
                     long(maxnpeaks), $
                     float(sigma), $
                     float(x), $
                     float(y), $
                     float(flux), $
                     long(npeaks))

if(npeaks gt 0) then begin
   x=x[0:npeaks-1]
   y=y[0:npeaks-1]
   flux=flux[0:npeaks-1]
endif else begin
   delvarx, x
   delvarx, y
   delvarx, flux
endelse

end
;------------------------------------------------------------------------------
