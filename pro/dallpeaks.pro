;+
; NAME:
;   dallpeaks
; PURPOSE:
;   find peaks in an image
; CALLING SEQUENCE:
;   dpeaks, image [, xcen=, ycen=, sigma=, dlim=, maxnpeaks= ]
; INPUTS:
;   image - [nx, ny] input image
; OPTIONAL INPUTS:
;   sigma - sky sigma (defaults to sigma clipped estimate)
;   dlim - limiting separation for identical peaks
;   maxnpeaks - maximum number of peaks to return
;   minpeak - minimum peak value (defaults to 1 sigma)
; OPTIONAL KEYWORDS:
;   /smooth - smooth a bit before finding
; OUTPUTS:
;   xcen, ycen - [nx, ny] positions of peaks
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dallpeaks, image, object, xcen=xcen, ycen=ycen, sigma=sigma

if(NOT keyword_set(dlim)) then dlim=1.
if(NOT keyword_set(sigma)) then sigma=djsig(image, sigrej=2)
if(NOT keyword_set(minpeak)) then minpeak=sigma
if(NOT keyword_set(saddle)) then saddle=3.
               
nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

maxper=300L
maxnpeaks=100000L
xcen=fltarr(maxnpeaks)
ycen=fltarr(maxnpeaks)
npeaks=0L
retval=call_external(soname, 'idl_dallpeaks', float(image), $
                     long(nx), long(ny), long(object), float(xcen), $
                     float(ycen), long(npeaks), float(sigma), float(dlim), $
                     float(saddle), long(maxper), long(maxnpeaks), $
                     float(minpeak))

xcen=xcen[0:npeaks-1]
ycen=ycen[0:npeaks-1]

end
;------------------------------------------------------------------------------
