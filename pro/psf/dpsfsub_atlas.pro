;+
; NAME:
;   dpsfsub_atlas
; PURPOSE:
;   subtract psfs 
; CALLING SEQUENCE:
;   subim= dpsfsub(imbas)
; INPUTS:
;   imbase - file base name (full name should be imbase+'.fits.gz')
; OUTPUTS:
;   subim - attempt at fitting and subtracting PSFs
; REVISION HISTORY:
;   1-Mar-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dpsfsub_atlas, imbase, nov=nov

image=gz_mrdfits(imbase+'.fits',0)
ivar=gz_mrdfits(imbase+'.fits',1)

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
psf=mrdfits(imbase+'-bpsf.fits')

simplexy, image, x, y
chi2= dpsfselect_atlas(image, ivar, x, y, psf=psf, dof=dof)
istar= where(chi2 lt dof+sqrt(2.*dof))
x=x[istar]
y=y[istar]

fit_mult_gauss, psf, 1, amp, psfsig, model=model, /quiet
fwhm=psfsig*2.*sqrt(2.*alog(2.))

npx=(size(psf,/dim))[0]
npy=(size(psf,/dim))[1]

cc=fltarr(npx,npy)+1.
xx=reform(replicate(1., npx)#findgen(npy), npx*npy)/float(npx)-0.5
yy=reform(findgen(npx)#replicate(1., npy), npx*npy)/float(npy)-0.5
rr=sqrt((xx-npx*0.5)^2+(yy-npy*0.5)^2)

cmodel=fltarr(7,npx*npy)
cmodel[0,*]=reform(psf/max(psf), npx*npy)
cmodel[1,*]=cc
cmodel[2,*]=xx
cmodel[3,*]=yy
cmodel[4,*]=xx*xx
cmodel[5,*]=yy*yy
cmodel[6,*]=xx*yy

amp=fltarr(n_elements(x))
model=fltarr(nx,ny)
for i=0L, n_elements(x)-1L do begin 
   cutout_image=fltarr(npx,npy) 
   cutout_ivar=fltarr(npx,npy) 
   cutout_ivar=cutout_ivar>0. 
   embed_stamp, cutout_image, image, npx/2L-x[i], npy/2L-y[i] 
   embed_stamp, cutout_ivar, ivar, npx/2L-x[i], npy/2L-y[i] 
   
   hogg_iter_linfit, cmodel, reform(cutout_image, npx*npy), $
                     replicate(1., npx*npy), coeffs, nsigma=30
   amp[i]=coeffs[0] 
   
   tmodel= coeffs#cmodel
   
   fmodel= ((reform(coeffs[0]*cmodel[0,*]/tmodel,npx, npy))<1.)>0.
   pmodel= cutout_image*fmodel
   embed_stamp, model, pmodel, x[i]-float(npx/2L), y[i]-float(npy/2L)
   
endfor

nimage= image-model

return, nimage

end
;------------------------------------------------------------------------------
