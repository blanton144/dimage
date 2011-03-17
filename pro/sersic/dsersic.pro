;+
; NAME:
;   dsersic
; PURPOSE:
;   run 2d sersic fitting on an image
; CALLING SEQUENCE:
;   dsersic,image [,invvar,xcen=,ycen=,psf=,sersicfit=, $
;      model=, /reinit, /fixsky, /fixcen]
; INPUTS:
;   image - [nx,ny] input image
; OPTIONAL INPUTS:
;   invvar - [nx,ny] input inverse variance [default to unity everywhere]
;   xcen - center of image [default to nx/2L]
;   ycen - center of image [default to ny/2L]
;   psf - [nxpsf,nypsf] estimated psf [default to just pixel convolution]
;   /reinit - don't use given sersicfit (if it exists) as initial conditions
;   /fixcen - fix the center at the input xcen, ycen
;   /fixsky - fix the sky to zero
; OUTPUTS:
;   sersicfit - sersic parameters fit
;   model - image of best fit model
; COMMENTS:
;   The input psf should be interpreted as an image of a delta
;    function source (pixel- and seeing-convolved)
; EXAMPLES:
;   
; BUGS:
;   sersic fitting by dsersic currently fails fake data tests
; PROCEDURES CALLED:
; REVISION HISTORY:
;   10-Sep-2003  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function dsersic_model, fitparam

common com_simple, image, invvar, nx, ny, psf, xcen, ycen, oldfitparam, $
  parinfo, oldmodel, addtemplate, step, simple

; we have to guarantee we don't fall out, since mpfit does not
use_fitparam=fitparam
for i=0L, n_elements(fitparam)-1L do $
  if(parinfo[i].limited[0]) then $
  use_fitparam[i]=use_fitparam[i] > parinfo[i].limits[0]
for i=0L, n_elements(fitparam)-1L do $
  if(parinfo[i].limited[1]) then $
  use_fitparam[i]=use_fitparam[i] < parinfo[i].limits[1]

; get profile
model=dfakegal(nx=nx,ny=ny,xcen=use_fitparam[2],ycen=use_fitparam[3], $
               ba=use_fitparam[6],phi0=use_fitparam[7], $
               r50=exp(use_fitparam[4]), sersicn=use_fitparam[5], $
               flux=1., simple=simple)

; convolve with seeing
if(n_elements(psf) gt 1) then model=convolve(model,psf)

; set flux linearly
if(NOT keyword_set(addtemplate)) then begin
;   case that no template is added
    use_fitparam[0]=total((image-use_fitparam[1])*model*invvar)/ $
      total(model^2*invvar)
    model=model*use_fitparam[0]+use_fitparam[1]
    fitparam[0]=use_fitparam[0]
endif else begin
;   if there is an extra template we are fitting ...
    if(step eq 0) then begin
        use_fitparam[8]=total((image-use_fitparam[1])*addtemplate*invvar)/ $
          total(addtemplate^2*invvar)
        use_fitparam[0]= $
          total((image-use_fitparam[1]-use_fitparam[8]*addtemplate)* $
                model*invvar)/total(model^2*invvar)
        fitparam[0]=use_fitparam[0]
        fitparam[8]=use_fitparam[8]
        model=model*use_fitparam[0]+addtemplate*use_fitparam[8]+use_fitparam[1]
    endif else begin
        mm=image-use_fitparam[1]
        bb=fltarr(2)
        aa=fltarr(2,2)
        bb[0]=total(mm*model*invvar,/double)
        bb[1]=total(mm*addtemplate*invvar,/double)
        aa[0,0]=total(model*model*invvar,/double)
        aa[0,1]=total(model*addtemplate*invvar,/double)
        aa[1,0]=aa[0,1]
        aa[1,1]=total(addtemplate*addtemplate*invvar,/double)
        coeffs=invert(aa)#bb
        if(coeffs[1] lt 0.) then begin
            coeffs[1]=0.
            coeffs[0]= $
              total((image-use_fitparam[1])*model*invvar)/ $
              total(model^2*invvar)
        endif else if(coeffs[0] lt 0.) then begin
            coeffs[0]=0.
            coeffs[1]= $
              total((image-use_fitparam[1])*addtemplate*invvar)/ $
              total(addtemplate^2*invvar)
        endif
        use_fitparam[0]=coeffs[0]
        use_fitparam[8]=coeffs[1]
        fitparam[0]=use_fitparam[0]
        fitparam[8]=use_fitparam[8]
        model=model*use_fitparam[0]+addtemplate*use_fitparam[8]+use_fitparam[1]
    endelse
endelse

return, model

end
;
function dsersic_func, fitparam

common com_simple

; calculate model
model=dsersic_model(fitparam)

; return residuals

return, reform(((model-image)*sqrt(invvar)),n_elements(model))

end
;
pro dsersic,in_image,in_invvar,xcen=in_xcen,ycen=in_ycen,psf=in_psf, $
            sersicfit=sersicfit,model=model, reinit=reinit, $
            fixcenter=fixcenter,fixsky=fixsky, addtemplate=in_addtemplate, $
            nofit=nofit, simple=in_simple, axisymmetric=axisymmetric, $
            onlyflux=onlyflux


if(n_params() lt 1) then begin
    print, 'Syntax - dsersic, image [, invvar, xcen=, ycen=, psf=, sersicfit=, model= '
    print, '                addtemplate=, /reinit, /fixcenter, /fixsky '
    return
endif

common com_simple

; defaults, etc.
addtemplate=0
nx=(size(in_image,/dim))[0]
ny=(size(in_image,/dim))[1]
if(n_elements(in_invvar) eq 0) then in_invvar=fltarr(nx,ny)+1.
if(n_elements(in_xcen) eq 0) then in_xcen=float(nx/2L)
if(n_elements(in_ycen) eq 0) then in_ycen=float(ny/2L)
if(n_elements(in_psf) eq 0) then in_psf=1
if(n_elements(in_addtemplate) gt 0) then addtemplate=in_addtemplate
if(n_elements(in_simple) gt 0) then simple=in_simple else simple=0
image=in_image
invvar=in_invvar
psf=in_psf
xcen=in_xcen
ycen=in_ycen
xcen_orig=xcen
ycen_orig=ycen
oldfitparam=0
fixsky=keyword_set(fixsky)
fixcen=keyword_set(fixcenter)
axisymmetric=keyword_set(axisymmetric)

; set initialization arbitrarily
if(n_tags(sersicfit) eq 0 OR keyword_set(reinit)) then begin
    sersicfit={sky:0., $     
               xcen:xcen, $   
               ycen:ycen, $
               sersicflux:total(image), $     
               sersicr50:20., $     
               sersicn:4., $     
               axisratio:0.5, $    
               orientation:45., $
               addcoeff:0., $
               ndof:0L, $
               chisquared:0., $
               fitparam: fltarr(9), $
               perror:   fltarr(9), $
               covariance:fltarr(9,9)}
endif
if(keyword_set(axisymmetric)) then sersicfit.axisratio=1.

; set up parinfo for mpfit
str1 = {value:0D,fixed:1B,limited:[1B,1B],limits:[0D,1D], $
        step:1D0, mpside:0}
parinfo = replicate(str1,9)
parinfo.step= $
  [    1.0,    1E-1,    0.2,    0.2,  0.02, 0.01, 0.01,     1.0, 1.]
parinfo.limited[0]= $
  [      0,       0,      1,      1,     1,    1,    1,       1, 0]
parinfo.limited[1]= $
  [      0,       0,      1,      1,     1,    1,    1,       1, 0]
parinfo.limits[0]=  $
  [     0.,  -1000.,     0.,     0., -1.20,  0.5, 0.15,    0.00, 0.00]
parinfo.limits[1]=  $
  [     1.,   1000.,     nx,     ny,  6.00,  6., 1.00,  360.00, 1.]
parinfo.fixed=      $
  [      1,  fixsky, fixcen, fixcen,     0,    0,    axisymmetric, axisymmetric, 1]
parinfo.value=      [sersicfit.sersicflux, $
                     sersicfit.sky, $
                     sersicfit.xcen, $
                     sersicfit.ycen, $
                     alog(sersicfit.sersicr50), $
                     sersicfit.sersicn, $
                     sersicfit.axisratio, $
                     sersicfit.orientation, $
                     sersicfit.addcoeff]

if(keyword_set(nofit) eq 0 AND $
   keyword_set(onlyflux) eq 0) then begin 

; search starting from two possible orientations
    chisquared=fltarr(2)
    parinfo0=parinfo
    parinfo0[6].value=parinfo[6].value
    parinfo0[7].value=45.
    step=1
    fitparam0= mpfit('dsersic_func',/autoderivative, $
                     maxiter=maxiter,parinfo=parinfo0,status=status, $
                     covar=covar0,ftol=1.e-10,perror=perror0)
    chisquared[0]=total(dsersic_func(fitparam0)^2)

    if(NOT keyword_set(axisymmetric)) then begin
        parinfo1=parinfo
        parinfo1[4].value=parinfo0[4].value
        parinfo1[5].value=parinfo0[5].value
        parinfo1[6].value=parinfo[6].value
        parinfo1[7].value=135.
        fitparam1= mpfit('dsersic_func',/autoderivative, $
                         maxiter=maxiter,parinfo=parinfo1, status=status,  $
                         covar=covar1,ftol=1.e-10,perror=perror1)
        help,status
        chisquared[1]=total(dsersic_func(fitparam1)^2)
    endif else begin
        chisquared[1]=chisquared[0]+10.
    endelse

; take better version
    if(chisquared[0] le chisquared[1]) then begin
        fitparam=fitparam0
        covar=covar0
        perror=perror0
    endif else begin
        fitparam=fitparam1
        covar=covar1
        perror=perror1
    endelse

    step=1
    chisquared=total(dsersic_func(fitparam)^2)

; construct output
    model=dsersic_model(fitparam)
    sersicfit.sersicflux=    fitparam[0]
    sersicfit.sky=           fitparam[1]
    sersicfit.xcen=          fitparam[2]
    sersicfit.ycen=          fitparam[3]
    sersicfit.sersicr50=     exp(fitparam[4])
    sersicfit.sersicn=       fitparam[5]
    sersicfit.axisratio=     fitparam[6]
    sersicfit.orientation=   fitparam[7]
    sersicfit.addcoeff=      fitparam[8]
    sersicfit.ndof=          n_elements(model)-total(parinfo.fixed EQ 0)
    sersicfit.chisquared=    chisquared
    sersicfit.fitparam=      fitparam
    sersicfit.perror=        perror
    sersicfit.covariance=    covar

    help,/st,sersicfit

endif else begin
    fitparam=[sersicfit.sersicflux, $
              sersicfit.sky, $
              sersicfit.xcen, $
              sersicfit.ycen, $
              alog(sersicfit.sersicr50), $
              sersicfit.sersicn, $
              sersicfit.axisratio, $
              sersicfit.orientation, $
              sersicfit.addcoeff]
    model=dsersic_model(fitparam)
    if(keyword_set(onlyflux)) then $
      sersicfit.sersicflux= fitparam[0]
endelse

end
