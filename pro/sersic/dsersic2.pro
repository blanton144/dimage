;+
; NAME:
;   dsersic2
; PURPOSE:
;   run 2d, two-component sersic fitting on an image
; CALLING SEQUENCE:
;   dsersic2,image [,invvar, xcen=, ycen=, psf=, sersicfit=, $
;      model=, seed=, /reinit, /fixsky, /fixcenter, /axisymmetric, /simple]
; INPUTS:
;   image - [nx,ny] input image
; OPTIONAL INPUTS:
;   invvar - [nx,ny] input inverse variance [default to unity everywhere]
;   xcen - center of image [default to nx/2L]
;   ycen - center of image [default to ny/2L]
;   psf - [nxpsf,nypsf] estimated psf [default to just pixel convolution]
;   seed - set seed for random initial conditions
; OPTIONAL KEYWORDS:
;   /reinit - don't use given sersicfit (if it exists) as initial conditions
;   /fixcenter - fix the center at the input xcen, ycen
;   /fixsky - do not allow sky to float
;   /axisymmetric - allow only axisymmetric fits
;   /simple - do not do full sersic integration (faster but less accurate)
;   /silent - shut up
;   /scramble - forces scramble of angles even if sersicfit set
; INPUTS/OUTPUTS:
;   sersicfit - sersic parameters fit (if set, and /reinit not, uses
;               as starting point)
; OUTPUTS:
;   model - image of best fit model
; COMMENTS:
;   The input psf should be interpreted as an image of a delta
;   function source (pixel- and seeing-convolved)
; REVISION HISTORY:
;   10-Sep-2003  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function dsersic2_model, fitparam

common com_dsersic2, image, invvar, nx, ny, psf, xcen, ycen, $
  parinfo, oldmodel, simple, outmodel1, outmodel2, $
  xcen_bulge, ycen_bulge

; we have to guarantee we don't fall out, since mpfit does not
use_fitparam=fitparam
for i=0L, n_elements(fitparam)-1L do $
  if(parinfo[i].limited[0]) then $
  use_fitparam[i]=use_fitparam[i] > parinfo[i].limits[0]
for i=0L, n_elements(fitparam)-1L do $
  if(parinfo[i].limited[1]) then $
  use_fitparam[i]=use_fitparam[i] < parinfo[i].limits[1]

; get profile
model1=dfakegal(nx=nx,ny=ny,xcen=xcen_bulge, ycen=ycen_bulge, $
               ba=use_fitparam[7],phi0=use_fitparam[8], $
               r50=exp(use_fitparam[5]), sersicn=use_fitparam[6], $
               flux=1., simple=simple)

model2=dfakegal(nx=nx,ny=ny,xcen=use_fitparam[3],ycen=use_fitparam[4], $
                ba=use_fitparam[11],phi0=use_fitparam[12], $
                r50=exp(use_fitparam[9]), sersicn=use_fitparam[10], $
                flux=1., simple=simple)

; convolve with seeing
if(n_elements(psf) gt 1) then model=convolve(model,psf)

; set flux linearly
mm=image-use_fitparam[2]
bb=fltarr(2)
aa=fltarr(2,2)
bb[0]=total(mm*model1*invvar,/double)
bb[1]=total(mm*model2*invvar,/double)
aa[0,0]=total(model1*model1*invvar,/double)
aa[0,1]=total(model1*model2*invvar,/double)
aa[1,0]=aa[0,1]
aa[1,1]=total(model2*model2*invvar,/double)
coeffs=invert(aa)#bb
if(coeffs[1] lt 0.) then begin
    coeffs[1]=0.
    coeffs[0]= $
      total((image-use_fitparam[2])*model1*invvar)/ $
      total(model1^2*invvar)
endif else if(coeffs[0] lt 0.) then begin
    coeffs[0]=0.
    coeffs[1]= $
      total((image-use_fitparam[2])*model2*invvar)/ $
      total(model2^2*invvar)
endif
use_fitparam[0]=coeffs[0]
use_fitparam[1]=coeffs[1]
fitparam[0]=use_fitparam[0]
fitparam[1]=use_fitparam[1]

outmodel1=model1*use_fitparam[0]
outmodel2=model2*use_fitparam[1]
model=model1*use_fitparam[0]+model2*use_fitparam[1]+use_fitparam[2]

return, model

end
;
function dsersic2_func, fitparam

common com_dsersic2

; calculate model
model=dsersic2_model(fitparam)

; return residuals
return, reform(((model-image)*sqrt(invvar)),n_elements(model))

end
;
pro dsersic2, in_image, in_invvar, xcen=in_xcen, ycen=in_ycen, psf=in_psf, $
              sersicfit=sersicfit,model=model, reinit=reinit, $
              fixcenter=fixcenter, fixsky=fixsky, $
              nofit=nofit, simple=in_simple, axisymmetric=axisymmetric, $
              bulge=bulge, disk=disk, seed=seed, silent=silent, $
              scramble=scramble


if(n_params() lt 1) then begin
    doc_library, 'dsersic2'
    return
endif

common com_dsersic2

; defaults
nx=(size(in_image,/dim))[0]
ny=(size(in_image,/dim))[1]
if(n_elements(in_invvar) eq 0) then in_invvar=fltarr(nx,ny)+1.
if(n_elements(in_xcen) eq 0) then in_xcen=float(nx/2L)
if(n_elements(in_ycen) eq 0) then in_ycen=float(ny/2L)
if(n_elements(in_psf) eq 0) then in_psf=1
if(n_elements(in_simple) gt 0) then simple=in_simple else simple=0
image=in_image
invvar=in_invvar
psf=in_psf
xcen=in_xcen
ycen=in_ycen
xcen_bulge=xcen
ycen_bulge=ycen
fixsky=keyword_set(fixsky)
fixcen=keyword_set(fixcenter)
axisymmetric=keyword_set(axisymmetric)

; set initialization arbitrarily
scramble=0
if(keyword_set(scramble)) then scramble=1
if(n_tags(sersicfit) eq 0 OR keyword_set(reinit)) then begin
    scramble=1
    sersicfit={sky:0., $     
               xcen:xcen, $   
               ycen:ycen, $
               sersic1flux:total(image), $     
               sersic1r50:3.+randomu(seed)*6., $     
               sersic1n:1.5+3.5*randomu(seed), $     
               orientation1:45., $
               axisratio1:0.5, $
               sersic2flux:total(image), $     
               sersic2r50:7.+randomu(seed)*6., $     
               sersic2n:0.8+randomu(seed)*0.4, $
               orientation2:45., $
               axisratio2:0.5, $
               ndof:0L, $
               chisquared:0., $
               fitparam: fltarr(13), $
               perror:   fltarr(13), $
               covariance:fltarr(13,13)}
endif
if(keyword_set(axisymmetric)) then sersicfit.axisratio1=1.
if(keyword_set(axisymmetric)) then sersicfit.axisratio2=1.

; set up parinfo for mpfit
str1 = {value:0D,fixed:1B,limited:[1B,1B],limits:[0D,1D], $
        step:1D0, mpside:0}
parinfo = replicate(str1,13)
parinfo.step= $
  [    1.0,    1., 1E-1,    0.2,    0.2,  0.02, 0.01, 0.01,  1., 0.02, 0.01, 0.01,   1.0 ]
parinfo.limited[0]= $
  [      0,    0.,    0,      1,      1,     1,    1,     1,  1, 1, 1, 1, 1]
parinfo.limited[1]= $
  [      0,    0,     0,      1,      1,     1,    1,     1. ,1., 1, 1., 1.,    1]
parinfo.limits[0]=  $
  [     0.,  0., -1000.,      0.,     0., -1.20,  0.3, 0.15, -20.00, -1.20, 0.8, 0.15, -20.00]
parinfo.limits[1]=  $
  [     1.,  1., -1000.,     nx,     ny,  6.00,  6., 1.00, 380.00, 6., 1.2, 1., 380.]
parinfo.fixed=      $
  [      1,  1, fixsky, fixcen, fixcen,     0,    0,    axisymmetric, axisymmetric, 0, 0, axisymmetric, axisymmetric]
parinfo.value=      [sersicfit.sersic1flux, $
                     sersicfit.sersic2flux, $
                     sersicfit.sky, $
                     sersicfit.xcen, $
                     sersicfit.ycen, $
                     alog(sersicfit.sersic1r50), $
                     sersicfit.sersic1n, $
                     sersicfit.axisratio1, $
                     sersicfit.orientation1, $
                     alog(sersicfit.sersic2r50), $
                     sersicfit.sersic2n, $
                     sersicfit.axisratio2, $
                     sersicfit.orientation2]

if(NOT keyword_set(nofit)) then begin 

; search starting from two possible orientations
    chisquared=fltarr(4)
    parinfo0=parinfo
    if(keyword_set(scramble) eq 1) then begin
        parinfo0[7].value=parinfo[7].value
        parinfo0[8].value=45.
        parinfo0[12].value=45.
    endif
    fitparam0= mpfit('dsersic2_func',/autoderivative, $
                     maxiter=maxiter,parinfo=parinfo0,status=status, $
                     covar=covar0,ftol=1.e-10,perror=perror0, $
                    quiet=silent)
    chisquared[0]=total(dsersic2_func(fitparam0)^2)
    help,chisquared[0]

    if(keyword_set(scramble) eq 1 AND $
       keyword_set(axisymmetric) eq 0) then begin

        parinfo1=parinfo
        parinfo1[5].value=parinfo0[5].value
        parinfo1[6].value=parinfo0[6].value
        parinfo1[7].value=parinfo[7].value
        parinfo1[8].value=135.
        parinfo1[9].value=parinfo0[9].value
        parinfo1[10].value=parinfo0[10].value
        parinfo1[11].value=parinfo[11].value
        parinfo1[12].value=135.
        fitparam1= mpfit('dsersic2_func',/autoderivative, $
                         maxiter=maxiter,parinfo=parinfo1, status=status,  $
                         covar=covar1,ftol=1.e-10,perror=perror1, $
                    quiet=silent)
        help,status
        chisquared[1]=total(dsersic2_func(fitparam1)^2)
        help,chisquared[1]

        parinfo2=parinfo
        parinfo2[5].value=parinfo1[5].value
        parinfo2[6].value=parinfo1[6].value
        parinfo2[7].value=parinfo[7].value
        parinfo2[8].value=45.
        parinfo2[9].value=parinfo1[9].value
        parinfo2[10].value=parinfo1[10].value
        parinfo2[11].value=parinfo[11].value
        parinfo2[12].value=135.
        fitparam2= mpfit('dsersic2_func',/autoderivative, $
                         maxiter=maxiter,parinfo=parinfo2, status=status,  $
                         covar=covar2,ftol=1.e-10,perror=perror2, $
                    quiet=silent)
        help,status
        chisquared[2]=total(dsersic2_func(fitparam2)^2)
        help,chisquared[2]

        parinfo3=parinfo
        parinfo3[5].value=parinfo2[5].value
        parinfo3[6].value=parinfo2[6].value
        parinfo3[7].value=parinfo[7].value
        parinfo3[8].value=135.
        parinfo3[9].value=parinfo2[9].value
        parinfo3[10].value=parinfo2[10].value
        parinfo3[11].value=parinfo[11].value
        parinfo3[12].value=45.
        fitparam3= mpfit('dsersic2_func',/autoderivative, $
                         maxiter=maxiter,parinfo=parinfo3, status=status,  $
                         covar=covar3,ftol=1.e-10,perror=perror3, $
                    quiet=silent)
        help,status
        chisquared[3]=total(dsersic2_func(fitparam3)^2)
        help,chisquared[3]
    endif else begin
        chisquared[1:3]=chisquared[0]+10.
    endelse

; take better version
    minchi=min(chisquared, imin)
    if(imin eq 0) then begin
        fitparam=fitparam0
        covar=covar0
        perror=perror0
    endif
    if(imin eq 1) then begin
        fitparam=fitparam1
        covar=covar1
        perror=perror1
    endif
    if(imin eq 2) then begin
        fitparam=fitparam2
        covar=covar2
        perror=perror2
    endif
    if(imin eq 3) then begin
        fitparam=fitparam3
        covar=covar3
        perror=perror3
    endif

    chisquared=total(dsersic2_func(fitparam)^2)

; construct output
    model=dsersic2_model(fitparam)
    sersicfit.sersic1flux=    fitparam[0]
    sersicfit.sersic2flux=    fitparam[1]
    sersicfit.sky=           fitparam[2]
    sersicfit.xcen=          fitparam[3]
    sersicfit.ycen=          fitparam[4]
    sersicfit.sersic1r50=     exp(fitparam[5])
    sersicfit.sersic1n=       fitparam[6]
    sersicfit.axisratio1=     fitparam[7]
    sersicfit.orientation1=   (fitparam[8]+360) mod 360.
    sersicfit.sersic2r50=     exp(fitparam[9])
    sersicfit.sersic2n=     fitparam[10]
    sersicfit.axisratio2=     fitparam[11]
    sersicfit.orientation2=   (fitparam[12]+360.) mod 360.
    sersicfit.ndof=          n_elements(model)-total(parinfo.fixed EQ 0)
    sersicfit.chisquared=    chisquared
    sersicfit.fitparam=      fitparam
    sersicfit.perror=        perror
    sersicfit.covariance=    covar

    help,/st,sersicfit

endif else begin
    fitparam=[sersicfit.sersic1flux, $
              sersicfit.sersic2flux, $
              sersicfit.sky, $
              sersicfit.xcen, $
              sersicfit.ycen, $
              alog(sersicfit.sersic1r50), $
              sersicfit.sersic1n, $
              sersicfit.axisratio1, $
              sersicfit.orientation1, $
              alog(sersicfit.sersic2r50), $
              sersicfit.sersic2n, $
              sersicfit.axisratio2, $
              sersicfit.orientation2]
    model=dsersic2_model(fitparam)
    help,fitparam[0]
    help,fitparam[1]
endelse

if(sersicfit.sersic1r50 lt sersicfit.sersic2r50 AND $
   sersicfit.sersic1flux gt 0) then begin
    bulge=outmodel1
    disk=outmodel2
endif else begin
    bulge=outmodel2
    disk=outmodel1
endelse

end
