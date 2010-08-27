;+
; NAME:
;   dpsfselect_atlas
; PURPOSE:
;   check how well a PSF fits some data
; CALLING SEQUENCE:
;   ispsf= dpsfselect_atlas(image, ivar, x, y [, psf=, amp= ])
; INPUTS:
;   image - [nx, ny] input image
;   ivar - [nx, ny] input invverse variance
;   x, y - [N] positions to check
;   psf - [npx, npy] PSF image
; OUTPUTS:
;   ispsf - [N] 1 for PSF, 0 otherwise
;   amp - amplitude of fit (after peak-normalizing PSF)
; REVISION HISTORY:
;   1-Aug-2010  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dpsfselect_atlas, image, ivar, x, y, amp=amp, psf=psf, flux=flux, $
                           dof=dof, subimage=subimage, noclip=noclip

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

npx=(size(psf,/dim))[0]
npy=(size(psf,/dim))[1]

subimage=image

dfit_mult_gauss, psf, 1, amp, psfsig, model=model, /quiet 
fwhm=psfsig*2.*sqrt(2.*alog(2.))

if(NOT keyword_set(noclip)) then begin
   ncx=long(fwhm[0]*4.) < npx
   ncy=long(fwhm[0]*4.) < npy
   xst= npx/2L-ncx/2L
   xnd= xst+ncx-1L
   yst= npy/2L-ncy/2L
   ynd= yst+ncy-1L
endif else begin
   xst=0L
   xnd=npx-1L
   yst=0L
   ynd=npy-1L
   ncx=npx
   ncy=npy
endelse

cc=fltarr(ncx,ncy)+1.
xx=reform(findgen(ncx)#replicate(1., ncy), ncx*ncy)/float(ncy)-0.5
yy=reform(replicate(1., ncx)#findgen(ncy), ncx*ncy)/float(ncx)-0.5
rr=sqrt((xx-ncx*0.5)^2+(yy-ncy*0.5)^2)


cenpsf= psf[xst:xnd, yst:ynd]

cmodel=fltarr(7,ncx*ncy)
cmodel[0,*]=reform(cenpsf/max(psf), ncx*ncy)
cmodel[1,*]=cc
cmodel[2,*]=xx
cmodel[3,*]=yy
cmodel[4,*]=xx*xx
cmodel[5,*]=yy*yy
cmodel[6,*]=xx*yy

amp=fltarr(n_elements(x))
flux=fltarr(n_elements(x))
chi2=fltarr(n_elements(x))
dof=fltarr(n_elements(x))+float(n_elements(cenpsf))-4.
for i=0L, n_elements(x)-1L do begin 
   cutout_image=fltarr(ncx,ncy) 
   cutout_ivar=fltarr(ncx,ncy) 

   embed_stamp, cutout_image, subimage, ncx/2L-x[i], ncy/2L-y[i] 
   embed_stamp, cutout_ivar, ivar, ncx/2L-x[i], ncy/2L-y[i] 
   cutout_ivar=cutout_ivar>0.
   
   hogg_iter_linfit, cmodel, reform(cutout_image, ncx*ncy), $
                     reform(cutout_ivar, ncx*ncy), coeffs, nsigma=10
   amp[i]=coeffs[0] 
   flux[i]=coeffs[0] 
   chi2[i]= total((reform(coeffs#cmodel, ncx*ncy)-reform(cutout_image, ncx*ncy))^2* $
                  reform(cutout_ivar, ncx*ncy))
   
   submodel= (reform(coeffs#cmodel, ncx,ncy)-reform(cutout_image, ncx,ncy))

   if(arg_present(subimage)) then begin
      subpsf= coeffs[0]*psf
      embed_stamp, subimage, -subpsf, x[i]-float(npx/2L), y[i]-float(npy/2L)
   endif

endfor

return, chi2

end
;------------------------------------------------------------------------------
