;+
; NAME:
;   fit_mult_gauss2d
; PURPOSE:
;   fit multiple gaussians centered at center to an image
; CALLING SEQUENCE:
;   fit_mult_gauss, image, xcen, ycen, ngauss, amp, covar
; INPUTS:
;   image - image to fit
;   ngauss - number of gaussians to fit
; OPTIONAL INPUTS:
; OUTPUTS:
;   amp - [ngauss] amplitude of gaussians
;   icovar - [ngauss,2,2] inverse covariance matrix of gaussians
; COMMENTS:
;   Allows off-diagonal covariances.
; REVISION HISTORY:
;   24-May-2013  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function dfit_mult_gauss2d_deviates, p
; x is radius^2

common com_dfit_mult_gauss2d_func, image, nx, ny

ngauss=n_elements(p)/5

model=fltarr(n_elements(x))

xcen= p[0]
ycen= p[1]
for i=0, ngauss-1 do begin
   amp= p[2+i*5L]
   icovar= reform(p[2+5*i+1L: 2+5*i+4L], 2,2)
   model=model+amp[i]*norm*exp(-0.5*x*ivar[i])
endfor

return, model

end
;
pro dfit_mult_gauss2d, in_image, in_xcen, in_ycen, ngauss, amp, sigma, model=model, quiet=quiet

common com_dfit_mult_gauss2d_func

image= in_image
xcen= in_xcen
ycen= in_ycen

maxreset=10
sigtol=1.e-3
sigmamax=10.

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
xx=(findgen(nx)#replicate(1.,ny)+0.5)
yy=(transpose(findgen(ny)#replicate(1.,nx))+0.5)
radius2=(xx-xcen)^2+(yy-ycen)^2

; set error
image_err=sqrt(image)
notindx=where(image gt 0.,notcount)
minerr=min(image_err[notindx])
indx=where(image le 0.,count)
if(count gt 0) then image_err[indx]=minerr
image_err=fltarr(nx,ny)+0.01

amp=1./double(ngauss)
sigma=2.*findgen(ngauss)+1.
tryagain=1
nreset=0
while(tryagain) do begin
    start=fltarr(ngauss*2)
    start[0:ngauss-1]=alog(amp)
    start[ngauss:2*ngauss-1]=alog(1./sigma^2)
    parinfo1={ limited:bytarr(2), limits:fltarr(2) }
    parinfo=replicate(parinfo1,2L*ngauss) 
    parinfo[ngauss:2*ngauss-1].limited[0]=1
    parinfo[ngauss:2*ngauss-1].limits[0]=alog(1./sigmamax^2)
    p=mpfitfun('dfit_mult_gauss2d_func', radius2, image, image_err, $
               start,ftol=1.d-10,bestnorm=chi2,quiet=quiet, $
               parinfo=parinfo)
;   HACK
;   if two sigmas come out identical, try again
    tryagain=0
    if(nreset lt maxreset) then begin
        sigma=exp(-0.5*p[ngauss:2*ngauss-1])
        for i=0L, ngauss-1L do $
          for j=i+1L, ngauss-1L do $
          if(abs(sigma[i]-sigma[j]) lt sigtol*sigma[i]) then begin
            tryagain=1
            sigma[j]=2.*max(sigma)
        endif
    endif
    nreset=nreset+1
endwhile

model=reform(dfit_mult_gauss2d_func(radius2,p),nx,ny)

amp=exp(p[0:ngauss-1])
sigma=exp(-0.5*p[ngauss:2*ngauss-1])

for i=0L, ngauss-1L do $
  for j=i+1L, ngauss-1L do $
  if(abs(sigma[i]-sigma[j]) lt sigtol*sigma[i]) then $
  splog,'WARNING: identical sigmas remain!!!'

end
;------------------------------------------------------------------------------
