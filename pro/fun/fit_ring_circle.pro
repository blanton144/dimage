;+
; NAME:
;   fit_ring_circle
; PURPOSE:
;   Fit parameters to ring_circle
; CALLING SEQUENCE:
;   ring=fit_ring_circle(image, ivar)
; INPUTS:
;   image, ivar - [NX, NY] image and inverse variance
; OUTPUTS:
;   ring - structure with ring information:
;               .XCEN
;               .YCEN
;               .RADIUS
;               .BA
;               .PHI
;               .WIDTH
;               .AMP
;               .NX
;               .NY
; REVISION HISTORY:
;   10-Sep-2011  Written by Mike Blanton, NYU
;-
function frc_model, param

common com_frc, image, ivar, ring, xx, yy

cc= fltarr(ring.nx, ring.ny)+1.
xx= (findgen(ring.nx)-float(ring.nx/2L))#replicate(1., ring.ny)
yy= replicate(1.,ring.nx)#(findgen(ring.ny)-float(ring.ny/2L))

;; translate params
ring.xcen= param[0]
ring.ycen= param[1]
ring.radius= param[2]
ring.ba= param[3]
ring.phi= param[4]
ring.width= param[5]
ring.sfactor= param[6]

;; get profile
rmodel= ring_circle(xcen=ring.xcen, ycen=ring.ycen, radius=ring.radius, $
                    ba=ring.ba, phi=ring.phi, width=ring.width, $
                    amp=1., nx=ring.nx, ny=ring.ny, sfactor=ring.sfactor)

nc=4L
bb=dblarr(nc)
aa=dblarr(nc,nc)
models= dblarr(ring.nx,ring.ny, nc)
models[*,*, 0]= rmodel
models[*,*, 1]= cc
models[*,*, 2]= xx
models[*,*, 3]= yy
for i=0L, nc-1L do $
   bb[i]= total(image*models[*,*,i]*ivar, /double)
for i=0L, nc-1L do $
   for j=0L, nc-1L do $
      aa[i,j]= total(models[*,*,j]*models[*,*,i]*ivar, /double)
coeffs=invert(aa)#bb

;; set flux linearly
ring.amp=coeffs[0]
ring.const=coeffs[1]
ring.sx=coeffs[2]
ring.sy=coeffs[3]
print, coeffs
model=reform(reform(models, ring.nx*ring.ny, nc)#coeffs, ring.nx, ring.ny)

return, model

end
;
function frc_func, param

common com_frc

; calculate model
model=frc_model(param)

return, reform(((model-image)*sqrt(ivar)),n_elements(model))

end
;
function fit_ring_circle, in_image, in_ivar, model=model, fix=fix, $
                          start=start

common com_frc

image= in_image
ivar= in_ivar

nx= (size(image, /dim))[0]
ny= (size(image, /dim))[1]

if(n_tags(start) gt 0) then begin
    ring= start
endif else begin
    ring= {XCEN: 116.977, $
           YCEN: 205.275, $
           RADIUS: 50.4843, $
           BA: 0.498539, $
           PHI: 85.0548, $
           WIDTH:5.9688, $
           AMP:0.03, $
           CONST:0.00, $
           SX:0.00, $
           SY:0.00, $
           SFACTOR:0., $
           NX:nx, $
           NY:ny, $
           CHI2:0., $
           NDOF:0.}
endelse

;; set up parinfo for mpfit
parinfo1 = {value:0D,fixed:0B,limited:[1B,1B],limits:[0D,1D], $
            step:1D0, mpside:0}
parinfo = replicate(parinfo1,7)
parinfo.step= $
   [    1.0,    1.0,    1.0,   0.02,  1.00, 0.10, 0.1]
parinfo.limits[0]=  $
   [   110.,  165.,    40.,     0.1,    45., 2.5, -20.]
parinfo.limits[1]=  $
   [   160.,  235.,    80,       1.,    135.,  12., 20.]
parinfo.value= [ring.xcen, $
                ring.ycen, $
                ring.radius, $
                ring.ba, $
                ring.phi, $
                ring.width, $
                ring.sfactor]
parinfo[5].fixed=0L ;; fix width
parinfo[6].fixed=1L ;; fix sfactor

;; search starting from two possible orientations
if(NOT keyword_set(fix)) then $
   param= mpfit('frc_func',/autoderivative, $
                maxiter=maxiter,parinfo=parinfo,status=status, $
                covar=covar,ftol=1.e-10,perror=perror) $
else $
   param= parinfo.value

model= frc_model(param)

ring.chi2= total(frc_func(param)^2)
igd= where(ivar gt 0, ngd)
ring.ndof=ngd
                 
return, ring

end
