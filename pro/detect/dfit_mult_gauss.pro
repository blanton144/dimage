;+
; NAME:
;   fit_mult_gauss
; PURPOSE:
;   fit multiple gaussians centered at center to an image
; CALLING SEQUENCE:
;   fit_mult_gauss, image, ngauss, amp, sigma 
; INPUTS:
;   image - image to fit
;   ngauss - number of gaussians to fit
; OPTIONAL INPUTS:
; OUTPUTS:
;   amp - [ngauss] amplitude of gaussians
;   sigma - [ngauss] sigma of gaussians
; OPTIONAL INPUT/OUTPUTS:
; COMMENTS:
; EXAMPLES:
; BUGS:
; PROCEDURES CALLED:
; REVISION HISTORY:
;   20-Aug-2003  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function dfit_mult_gauss_func, x, p
; x is radius^2

ngauss=n_elements(p)/2
amp=exp(p[0:ngauss-1])
ivar=exp(p[ngauss:2*ngauss-1])
model=fltarr(n_elements(x))
for i=0, ngauss-1 do begin
    norm=(ivar[i]/(2.*!DPI))
    model=model+amp[i]*norm*exp(-0.5*x*ivar[i])
endfor

return, model

end
;
pro dfit_mult_gauss, image, ngauss, amp, sigma, model=model, quiet=quiet

maxreset=10
sigtol=1.e-3
sigmamax=10.

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
xx=findgen(nx)#replicate(1.,ny)+0.5
yy=transpose(findgen(ny)#replicate(1.,nx))+0.5
radius2=(xx-float(nx)/2.)^2+(yy-float(ny)/2.)^2

; set error
image_err=sqrt(image)
notindx=where(image gt 0.,notcount)
minerr=min(image_err[notindx])
indx=where(image le 0.,count)
if(count gt 0) then image_err[indx]=minerr
image_err=fltarr(nx,ny)+0.01

amp=1./double(ngauss)
sigma=findgen(ngauss)+1.
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
    p=mpfitfun('dfit_mult_gauss_func', radius2, image, image_err, $
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

model=reform(dfit_mult_gauss_func(radius2,p),nx,ny)

amp=exp(p[0:ngauss-1])
sigma=exp(-0.5*p[ngauss:2*ngauss-1])

for i=0L, ngauss-1L do $
  for j=i+1L, ngauss-1L do $
  if(abs(sigma[i]-sigma[j]) lt sigtol*sigma[i]) then $
  splog,'WARNING: identical sigmas remain!!!'

end
;------------------------------------------------------------------------------
