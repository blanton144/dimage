;+
; NAME:
;   dpsfcheck
; PURPOSE:
;   check how well a PSF fits some data
; CALLING SEQUENCE:
;   dpsfcheck, image, ivar, x, y [, psf= ]
; INPUTS:
;   image - [nx, ny] input image
;   ivar - [nx, ny] input invverse variance
;   x, y - [N] positions to check
; OPTIONAL INPUTS:
;   psf - sigma of PSF
; REVISION HISTORY:
;   1-Mar-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dpsfapprox, image, ivar, x, y, amp=amp

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
num=60
psfmin=0.5
psfmax=5.

chi2=fltarr(num)
psf=fltarr(num)
scale=fltarr(num)
nn=20L
xst=long(x-nn)>0L 
xnd=long(x+nn)<(nx-1L) 
xs=xnd-xst+1L 
yst=long(y-nn)>0L 
ynd=long(y+nn)<(ny-1L) 
ys=ynd-yst+1L 
cutout=image[xst:xnd, yst:ynd] 
cutout=cutout-median(cutout)
ivcut=ivar[xst:xnd, yst:ynd] 
xx=(xst+findgen(xs))#replicate(1., ys) 
yy=replicate(1., xs)#(yst+findgen(ys)) 
for j=0L, num-1L do begin 
    psf[j]=exp(alog(psfmin)+(alog(psfmax)-alog(psfmin))* $
               (float(j)+0.5)/float(num) )
    model=exp(-0.5*((xx-x)^2+(yy-y)^2)/psf[j]^2) 
    scale[j]=total(model*cutout*ivcut)/total(model*model*ivcut) 
    model=model*scale[j] 
    chi2[j]=total((cutout-model)^2*ivcut)
endfor
chi2min=min(chi2, imin)

return, psf[imin]

end
;------------------------------------------------------------------------------
