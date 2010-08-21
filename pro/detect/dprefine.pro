;+
; NAME:
;   dprefine
; PURPOSE:
;   refine a psf center
; CALLING SEQUENCE:
;   dprefine, image, psf, xc, yc, [, xr=, yr= ]
; INPUTS:
;   image - [nx, ny] image
;   psf - [npx, npy] estimated psf
;   xc, yc - [N] centers to refine around
; OUTPUTS:
;   xr, yr - [N] output centers
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function dprefine_model, fitparam

common com_prefine, image, nx, ny, psf, nn, curr_x, curr_y, invvar, parinfo

; we have to guarantee we don't fall out, since mpfit does not
use_fitparam=fitparam
for i=0L, n_elements(fitparam)-1L do $
  if(parinfo[i].limited[0]) then $
  use_fitparam[i]=use_fitparam[i] > parinfo[i].limits[0]
for i=0L, n_elements(fitparam)-1L do $
  if(parinfo[i].limited[1]) then $
  use_fitparam[i]=use_fitparam[i] < parinfo[i].limits[1]

curr_x= use_fitparam[0]
curr_y= use_fitparam[1]

model=sshift2d(psf, [curr_x, curr_y])

scale=total(image*model)/total(model*model)
model=scale*model

return, model

end
;
function dprefine_func, fitparam

common com_prefine

; calculate model
model=dprefine_model(fitparam)

; return residuals
return, reform(((model-image)*sqrt(invvar)),n_elements(model))

end
;
pro dprefine,in_image,in_psf, in_xcen,in_ycen,xr=xr, yr=yr, model=model, $
             cutout=cutout, invvar=in_invvar

common com_prefine


; defaults, etc.
nn=13L
nx=(size(in_image,/dim))[0]
ny=(size(in_image,/dim))[1]
npx=(size(in_psf,/dim))[0]
npy=(size(in_psf,/dim))[1]
xcen=in_xcen
ycen=in_ycen
xcen_orig=long(xcen)
ycen_orig=long(ycen)

if(NOT keyword_set(in_invvar)) then begin
   sig=dsigma(in_image)
   invvar=fltarr(nx,ny)+1./sig^2
endif else begin
   invvar=in_invvar
endelse

xlo_orig=(xcen_orig-nn/2L)
ylo_orig=(ycen_orig-nn/2L)
xhi_orig=(xcen_orig+nn/2L)
yhi_orig=(ycen_orig+nn/2L)
xlo=(xcen_orig-nn/2L)>0L
ylo=(ycen_orig-nn/2L)>0L
xhi=(xcen_orig+nn/2L)<(nx-1L)
yhi=(ycen_orig+nn/2L)<(ny-1L)
xoff=xlo-xlo_orig
yoff=ylo-ylo_orig

nfx=xhi-xlo+1L
nfy=yhi-ylo+1L

image=fltarr(nn, nn)
image[xoff:xoff+nfx-1L, yoff:yoff+nfy-1L]= $
  in_image[xlo:xhi, ylo:yhi]
psf=fltarr(nn, nn)
psf[xoff:xoff+nfx-1L, yoff:yoff+nfy-1L]= $
  in_psf[npx/2L-nn/2L+xoff:npx/2L-nn/2L+xoff+nfx-1, $
         npy/2L-nn/2L+yoff:npy/2L-nn/2L+yoff+nfy-1]

; set up parinfo for mpfit
str1 = {value:0D,fixed:1B,limited:[1B,1B],limits:[0D,1D], $
        step:1D0, mpside:0}
parinfo = replicate(str1,2)
parinfo.step= $
  [    0.1,  0.1]
parinfo.limited[0]= $
  [      1,       1]
parinfo.limited[1]= $
  [      1,       1]
parinfo.limits[0]=  $
  [     -2.,  -2.]
parinfo.limits[1]=  $
  [     2.,    2.]
parinfo.fixed=      $
  [      0,     0] 
parinfo.value= [0., 0.]

fitparam= mpfit('dprefine_func',/autoderivative, $
                maxiter=maxiter,parinfo=parinfo,status=status, $
                covar=covar,ftol=1.e-10,perror=perror, /quiet)

xr=xcen_orig+fitparam[0]
yr=ycen_orig+fitparam[1]

model=dprefine_model(fitparam)
cutout=image

return

end
