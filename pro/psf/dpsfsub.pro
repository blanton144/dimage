;+
; NAME:
;   dpsfsub
; PURPOSE:
;   return an attempt at subtracting the fit PSF from some image
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
function dpsfsub, imbase

image=mrdfits(imbase+'.fits.gz',0)
nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
vpsf=dpsfread(imbase+'-vpsf.fits')

sig=dsigma(image)
ivar=fltarr(nx,ny)+1./sig^2

dpeaks, image, xc=x, yc=y, /smooth, /refine

havevar=1
psf=dvpsf(nx*0.5, ny*0.5, psfsrc=vpsf)
fit_mult_gauss, psf, 1, amp, psfsig, model=model, /quiet
fwhm=psfsig*2.*sqrt(2.*alog(2.))

npx=(size(psf,/dim))[0]
npy=(size(psf,/dim))[1]

cc=fltarr(npx,npy)+1.
xx=reform(replicate(1., npx)#findgen(npy), npx*npy)/float(npx)-0.5
yy=reform(findgen(npx)#replicate(1., npy), npx*npy)/float(npy)-0.5
rr=sqrt((xx-npx*0.5)^2+(yy-npy*0.5)^2)

cmodel=fltarr(4,npx*npy)
cmodel[0,*]=reform(psf/max(psf), npx*npy)
cmodel[1,*]=xx
cmodel[2,*]=yy
cmodel[3,*]=cc

amp=fltarr(n_elements(x))
for i=0L, n_elements(x)-1L do begin 
    cutout_image=fltarr(npx,npy) 
    cutout_ivar=fltarr(npx,npy) 
    cutout_ivar=cutout_ivar>0. 
    embed_stamp, cutout_image, image, npx/2L-x[i], npy/2L-y[i] 
    embed_stamp, cutout_ivar, ivar, npx/2L-x[i], npy/2L-y[i] 
    
    if(keyword_set(havevar)) then begin
        currpsf=dvpsf(x[i], y[i], psfsrc=vpsf)
        cmodel[0,*]=reform(currpsf/max(currpsf), npx, npy) 
    endif else begin
        currpsf=psf
    endelse
    hogg_iter_linfit, cmodel, reform(cutout_image, npx*npy), $
      reform(cutout_ivar, npx*npy), coeffs, nsigma=30
    amp[i]=coeffs[0] 
endfor

model=fltarr(nx,ny)
for i=0L, n_elements(x)-1L do begin 
    if(keyword_set(havevar)) then begin
        currpsf=dvpsf(x[i], y[i], psfsrc=vpsf)
        cmodel[0,*]=reform(currpsf/max(currpsf), npx, npy) 
    endif else begin
        currpsf=psf
    endelse
    embed_stamp, model, amp[i]*currpsf/max(currpsf), $
      x[i]-float(npx/2L), y[i]-float(npy/2L)
endfor
nimage= image-model

return, nimage

end
;------------------------------------------------------------------------------
