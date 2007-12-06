;+
; NAME:
;   deblend
; PURPOSE:
;   deblend galaxies in an image
; CALLING SEQUENCE:
;   deblend, image, invvar [, sigma=, dlim=, nchild=, xcen=, ycen=, $
;     children=, templates= ]
; INPUTS:
;   image - [nx, ny] input image
;   invvar - [nx, ny] inverse variance image
; OPTIONAL INPUTS:
;   sigma - typical sky sigma (default is taken from inverse variance image)
;   dlim - closest two peaks can be
;   minpeak - minimum peak level to consider
; OUTPUTS:
;   nchild - number of children
;   xcen - [nchild] x centers of children
;   ycen - [nchild] y centers of children
;   children - [nx, ny, nchild] images of children
;   templates - [nx, ny, nchild] images of templates
; COMMENTS:
;   Only works in a single band.
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU, based on RHL deblend
;-
;------------------------------------------------------------------------------
pro deblend, image, invvar, nchild=nchild, xcen=xcen, ycen=ycen, $
             children=children, templates=templates, sigma=sigma, $
             dlim=dlim, saddle=saddle, tlimit=tlimit, minpeak=minpeak, $
             xpeaks=xpeaks, ypeaks=ypeaks, xstars=xstars, ystars=ystars, $
             xgals=xgals, ygals=ygals, psf=psf

if(NOT keyword_set(maxnchild)) then maxnchild=32L
if(NOT keyword_set(dlim)) then dlim=1.
if(NOT keyword_set(tlimit)) then tlimit=0.01
if(NOT keyword_set(tfloor)) then tfloor=0.01
if(NOT keyword_set(tsmooth)) then tsmooth=1.
if(NOT keyword_set(saddle)) then saddle=1.
if(NOT keyword_set(parallel)) then parallel=0.5
if(NOT keyword_set(sigma)) then sigma=1./sqrt(median(invvar))
if(NOT keyword_set(minpeak)) then minpeak=sigma
starstart=maxnchild

if(n_elements(xgals) gt 0) then begin
    xpeaks=xgals
    ypeaks=ygals
    starstart=n_elements(xgals)
endif

if(xstars[0] gt 0) then begin
    if(xpeaks[0] gt 0) then begin
        starstart=n_elements(xpeaks)
        xpeaks=[xpeaks, xstars]
        ypeaks=[ypeaks, ystars]
    endif else begin
        xpeaks=xstars
        ypeaks=ystars
        starstart=0
    endelse
endif

if(xpeaks[0] gt 0) then maxnchild=n_elements(xpeaks)

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
psf=psf>1.e-10
pnx=(size(psf,/dim))[0]
pny=(size(psf,/dim))[1]

xcen=lonarr(maxnchild)
ycen=lonarr(maxnchild)
children=fltarr(nx, ny, maxnchild)
;;templates=fltarr(nx, ny, maxnchild)
minvvar=median(invvar)
sigma=1./sqrt(minvvar)

; Set source object name
soname=filepath('libdimage.'+idlutils_so_ext(), $
                root_dir=getenv('DIMAGE_DIR'), subdirectory='lib')

nchild=0L
if(xpeaks[0] gt 0) then begin
    nchild=n_elements(xpeaks)
    xcen[0:nchild-1L]=xpeaks
    ycen[0:nchild-1L]=ypeaks
endif
retval=call_external(soname, 'idl_deblend', float(image), $
                     float(invvar), $
                     long(nx), long(ny), $
                     long(nchild), $
                     long(xcen), $
                     long(ycen), $
                     float(children), $
                     float(templates), $
                     float(sigma), $
                     float(dlim), $
                     float(tsmooth), $
                     float(tlimit), $
                     float(tfloor), $
                     float(saddle), $
                     float(parallel), $
                     long(maxnchild), $
                     float(minpeak), $
                     long(starstart), $
                     float(psf), $
                     long(pnx), $
                     long(pny), $
                     long(1))

if(nchild eq 0) then return

xcen=xcen[0:nchild-1L]
ycen=ycen[0:nchild-1L]
children=children[*,*,0:nchild-1L]
templates=templates[*,*,0:nchild-1L]

end
;------------------------------------------------------------------------------
