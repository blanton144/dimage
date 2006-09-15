;+
; NAME:
;   dobjects
; PURPOSE:
;   detect objects in an image
; CALLING SEQUENCE:
;   dobjects, image, objects= [, dpsf=, plim=, sigma=]
; INPUTS:
;   image - [nx, ny] original image
; OPTIONAL INPUTS:
;   dpsf - smoothing of PSF for detection (defaults to sigma=1 pixel)
;   plim - limiting significance in sky sigma (defaults to 5 sig )
;   sigma - typical sky sigma (default is taken from inverse variance image)
; OUTPUTS:
;   objects - [nx, ny] which object each pixel belongs to (-1 if none)
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dobjects, image, objects=objects, dpsf=dpsf, $
              plim=plim, smooth=smooth

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

if(NOT keyword_set(dpsf)) then dpsf=1.
if(NOT keyword_set(plim)) then plim=10.

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

nchild=0L
objects=lonarr(nx,ny)
smooth=fltarr(nx,ny)
retval=call_external(soname, 'idl_dobjects', $
                     float(image), $
                     float(smooth), $
                     long(nx), long(ny), $
                     float(dpsf), $
                     float(plim), $
                     long(objects))

end
