;+
; NAME:
;   dclumpy
; PURPOSE:
;   measure clumpiness of a galaxy image
; CALLING SEQUENCE:
;   dclumpy, image, xcen, ycen, annulus, smooth [, ba=, phi=, $
;      clumpy=, dflags= ]
; INPUTS:
;   image - [nx,ny] input image
;   xcen, ycen - initial x,y center
;   annulus - [inner, outer] annulus of measurement
;   smooth - gaussian smoothing sigma
; OPTIONAL INPUTS:
;   ba, phi - use elliptical region (annuli are major axis)
; OUTPUTS:
;   clumpy - clumpiness of image
;   dflags - flags with results
; REVISION HISTORY:
;   10-Aug-2008  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dclumpy, image, ivar, xcen, ycen, annulus, smooth, clumpy=clumpy, $
             ba=ba, phi=phi, dflags=dflags

if(NOT keyword_set(ba)) then ba=1.
if(NOT keyword_set(phi)) then phi=0.
if(NOT keyword_set(dflags)) then dflags=0L

;; make noise image
nx=(size(image, /dim))[0]
ny=(size(image, /dim))[1]
noise= randomn(seed, nx, ny)
nimage= fltarr(nx, ny)
ii=where(ivar gt 0, nii)
if(nii eq 0) then begin
    dflags= dflags OR dimage_flagval('DFLAGS', 'ZERO_IVAR')
    clumpy=0.
    return
endif
nimage[ii]= noise[ii]/sqrt(ivar[ii])

;; get radius image
xx= findgen(nx)#replicate(1.,ny)-xcen
yy= (replicate(1.,nx)#findgen(ny)-ycen)
rr= sqrt(xx^2+yy^2)
rrsquash= sqrt(xx^2+(yy/ba)^2)
rrrot= polywarp_rotate(rrsquash, phi, center=[xcen, ycen]) 
  
simage= dmedsmooth(image, box=smooth)
snimage= dmedsmooth(nimage, box=smooth)
imeas= where(rrrot lt annulus[1] and rrrot gt annulus[0] AND ivar gt 0, nmeas)
if(nmeas gt 0) then begin
    totimage= total(image[imeas])
    if(totimage gt 0.) then begin
        diff_raw=fltarr(nx,ny)
        diff_raw[imeas]=image[imeas]-simage[imeas]
        clumpy_raw= total(abs(diff_raw>0.))/(totimage)
        diff_noise=fltarr(nx,ny)
        diff_noise[imeas]=nimage[imeas]-snimage[imeas]
        clumpy_noise= total(abs(diff_noise>0.))/(totimage)
        clumpy= clumpy_raw-clumpy_noise
    endif else begin
        dflags= dflags OR dimage_flagval('DFLAGS', 'NOPIX_IN_CLUMPY')
        clumpy=0.
    endelse 
endif else begin
    dflags= dflags OR dimage_flagval('DFLAGS', 'NOPIX_IN_CLUMPY')
    clumpy=0.
endelse

end
