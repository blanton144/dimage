;+
; NAME:
;   dasymmetry
; PURPOSE:
;   measure asymmetry in the image
; CALLING SEQUENCE:
;   dasymmetry, image, ivar, xcen, ycen, radius, [ axcen=, aycen=, $
;     asymmetry=, ba=, phi= ]
; INPUTS:
;   image - [nx,ny] input image
;   ivar - [nx,ny] inverse variance of input image
;   xcen, ycen - initial x,y center
;   radius - radius of measurement
; OPTIONAL INPUTS:
;   axcen - best asymmetry center of image 
;   aycen - best asymmetry center of image 
;   ba, phi - use elliptical region (radius is major axis)
; OUTPUTS:
;   asymmetry - asymmetry of image
;   dflags - flags with results
; REVISION HISTORY:
;   10-Aug-2008  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dasymmetry, image, ivar, xcen, ycen, radius, axcen=axcen, aycen=aycen, $
                asymmetry=asymmetry, ba=ba, phi=phi, dflags=dflags

if(NOT keyword_set(ba)) then ba=1.
if(NOT keyword_set(phi)) then phi=0.
if(NOT keyword_set(dflags)) then dflags=0L

if(phi NE phi OR ba NE ba) then begin
    phi=0.
    ba=1.
endif

axcen= xcen
aycen= ycen
angle= 180.

;; make noise image
nx=(size(image, /dim))[0]
ny=(size(image, /dim))[1]
noise= randomn(seed, nx, ny)
nimage= fltarr(nx, ny)
ii=where(ivar gt 0, nii)
if(nii eq 0) then begin
    dflags= dflags OR dimage_flagval('DFLAGS', 'ZERO_IVAR')
    asymmetry=0
    return
endif
nimage[ii]= noise[ii]/sqrt(ivar[ii])

;; get radius image
xx= findgen(nx)#replicate(1.,ny)-axcen
yy= (replicate(1.,nx)#findgen(ny)-aycen)
rr= sqrt(xx^2+yy^2)
rrsquash= sqrt(xx^2+(yy/ba)^2)
rrrot= polywarp_rotate(rrsquash, phi, center=[axcen, aycen])

;; get raw asymmetry 
rotimage= polywarp_rotate(image, angle, center=[axcen, aycen])
rotnimage= polywarp_rotate(nimage, angle, center=[axcen, aycen])
imeas= where(rr lt radius and rrrot lt radius and ivar gt 0, nmeas)
if(nmeas gt 0) then begin
    totimage= total(image[imeas])
    if(totimage gt 0.) then begin
        asymmetry_raw= $
          total(abs(rotimage[imeas]-image[imeas]))/ $
          (2.*totimage)
        asymmetry_noise= $
          total(abs(rotnimage[imeas]-nimage[imeas]))/ $
          (2.*totimage)
        asymmetry= asymmetry_raw-asymmetry_noise
    endif else begin
        dflags= dflags OR dimage_flagval('DFLAGS', 'NOPIX_IN_ASYMMETRY')
        asymmetry=0.
    endelse 
endif else begin
    dflags= dflags OR dimage_flagval('DFLAGS', 'NOPIX_IN_ASYMMETRY')
    asymmetry=0.
endelse

end
