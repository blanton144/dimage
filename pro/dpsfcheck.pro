;+
; NAME:
;   dpsfcheck
; PURPOSE:
;   check how well a PSF fits some data
; CALLING SEQUENCE:
;   ispsf= dpsfcheck(image, ivar, x, y [, psf=, amp= ])
; INPUTS:
;   image - [nx, ny] input image
;   ivar - [nx, ny] input invverse variance
;   x, y - [N] positions to check
;   psf - [npx, npy] PSF image
; OUTPUTS:
;   ispsf - [N] 1 for PSF, 0 otherwise
;   amp - amplitude of fit (after peak-normalizing PSF)
; COMMENTS:
;   Fits a simple linear background plus the PSF.  Subtracts off the
;   model, median smoothes the image in FWHM boxes, and calls it a PSF
;   if the median smoothed image is < 0.1 times the original image at
;   the PSF peak. 
; REVISION HISTORY:
;   1-Mar-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dpsfcheck, image, ivar, x, y, amp=amp, psf=psf

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
npx=(size(psf,/dim))[0]
npy=(size(psf,/dim))[1]

fit_mult_gauss, psf, 1, amp, psfsig, model=model
fwhm=psfsig*2.*sqrt(2.*alog(2.))

cc=fltarr(npx,npy)+1.
xx=reform(replicate(1., npx)#findgen(npy), npx*npy)/float(npx)-0.5
yy=reform(findgen(npx)#replicate(1., npy), npx*npy)/float(npy)-0.5
rr=sqrt((xx-npx*0.5)^2+(yy-npy*0.5)^2)

cmodel=fltarr(npx*npy, 4)
cmodel[*,0]=reform(psf/max(psf), npx*npy)
cmodel[*,1]=xx
cmodel[*,2]=yy
cmodel[*,3]=cc

amp=fltarr(n_elements(x))
for i=0L, n_elements(x)-1L do begin 
    cutout_image=fltarr(npx,npy) 
    cutout_ivar=fltarr(npx,npy) 
    cutout_ivar=cutout_ivar>0. 
    embed_stamp, cutout_image, image, npx/2L-x[i], npy/2L-y[i] 
    embed_stamp, cutout_ivar, ivar, npx/2L-x[i], npy/2L-y[i] 
    
    hogg_iter_linfit, cmodel, reform(cutout_image, npx*npy), $
      reform(cutout_ivar, npx*npy), coeffs, nsigma=10 
    amp[i]=coeffs[0] 
endfor

model=fltarr(nx,ny)
for i=0L, n_elements(x)-1L do $ 
  embed_stamp, model, amp[i]*psf/max(psf), $
  x[i]-float(npx/2L), y[i]-float(npy/2L)
nimage= image-model
simage=dmedsmooth(nimage,box=ceil(fwhm)) 

ispsf=image[long(x), long(y)] gt 10.*simage[long(x), long(y)]

return, ispsf

end
;------------------------------------------------------------------------------
