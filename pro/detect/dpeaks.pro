;+
; NAME:
;   dpeaks
; PURPOSE:
;   find peaks in an image
; CALLING SEQUENCE:
;   dpeaks, image [, xcen=, ycen=, sigma=, dlim=, maxnpeaks=, $
;      saddle=, minpeak=, npeaks=, /smooth, /checkpeaks, /refine, $
;      /abssaddle ]
; INPUTS:
;   image - [nx, ny] input image
; OPTIONAL INPUTS:
;   sigma - sky sigma (defaults to estimate from dsigma.pro)
;   dlim - limiting separation for identical peaks (default 1)
;   maxnpeaks - maximum number of peaks to return (default 1000)
;   minpeak - minimum peak value (defaults to 1 sigma)
;   saddle - saddle point limit when checking peak separation ;
;            in absolute units if /abssaddle set, in units of sigma 
;            otherwise (default 3.)
; OPTIONAL KEYWORDS:
;   /smooth - smooth a bit before finding
;   /checkpeaks - check for peaks which are too connected to each other
;   /refine - refines peak estimates
;   /abssaddle - use absolue saddle point, not relative to peak
; OUTPUTS:
;   xcen, ycen - [npeaks] positions of peaks
;   npeaks - number of peaks
; COMMENTS:
;   When /checkpeaks is set, checks whether saddle points between peak
;     pairs are > peak-saddle*sigma; if so, those peaks are joined.
;   When /refine is not set, just finds to nearest pixel; when /refine
;     is set, uses gaussian approximation to guess peak center.
;   When /abssaddle is set, "saddle" yields the actual value the
;     saddle point needs to exceed, not the number of sigma less than
;     the peak
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dpeaks, image, xcen=xcen, ycen=ycen, sigma=sigma, dlim=dlim, $
            maxnpeaks=maxnpeaks, saddle=saddle, smooth=smooth, $
            minpeak=minpeak, refine=refine, npeaks=npeaks, $
            checkpeaks=checkpeaks, abssaddle=abssaddle

if(NOT keyword_set(maxnpeaks)) then maxnpeaks=1000
if(NOT keyword_set(dlim)) then dlim=1.
if(NOT keyword_set(sigma)) then sigma=dsigma(image, sp=4)
if(NOT keyword_set(minpeak)) then minpeak=5.*sigma
if(NOT keyword_set(saddle)) then saddle=3.
if(NOT keyword_set(smooth)) then smooth=0
if(NOT keyword_set(abssaddle)) then abssaddle=0

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

xcen=lonarr(maxnpeaks)
ycen=lonarr(maxnpeaks)
npeaks=0L
checkpeaks=keyword_set(checkpeaks)
retval=call_external(soname, 'idl_dpeaks', float(image), $
                     long(nx), long(ny), long(npeaks), long(xcen), $
                     long(ycen), float(sigma), float(dlim), float(saddle), $
                     long(maxnpeaks), long(smooth), long(checkpeaks), $
                     float(minpeak), long(abssaddle))

if(npeaks eq 0) then return

xcen=xcen[0:npeaks-1]
ycen=ycen[0:npeaks-1]

if(keyword_set(refine)) then begin
    xcenold=long(xcen)
    ycenold=long(ycen)
    drefine, image, xcenold, ycenold, smooth=1., xr=xcen, yr=ycen
endif

end
;------------------------------------------------------------------------------
