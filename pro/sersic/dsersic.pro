;+
; NAME:
;   dsersic
; PURPOSE:
;   run 2d sersic fitting on an image
; CALLING SEQUENCE:
;   dsersic, image [, invvar, xcen=, ycen=, psf=, sersicfit=, $
;      model=, /reinit, /fixsky, /fixcenter, /simple, $
;      /axisymmetric, /onlyflux]
; INPUTS:
;   image - [nx,ny] input image
; OPTIONAL INPUTS:
;   invvar - [nx,ny] input inverse variance [default to unity everywhere]
;   xcen - center of image [default to nx/2L]
;   ycen - center of image [default to ny/2L]
;   psf - [nxpsf,nypsf] estimated psf [default to just pixel convolution]
;   /reinit - don't use given sersicfit (if it exists) as initial conditions
;   /fixcenter - fix the center at the input xcen, ycen
;   /fixsky - fix the sky to zero
;   /axisymmetric - fix axis ratio to unity
;   /onlyflux - just fit for the flux, nothing else
;   /simple - just evaluate Sersic at each pixel, don't integrate it
; INPUT/OUTPUTS:
;   sersicfit - sersic parameters fit (interpreted as input if
;               /onlyflux set); structure with elements:
;                    .SKY
;                    .XCEN
;                    .YCEN
;                    .SERSICFLUX
;                    .SERSICFLUX_IVAR
;                    .SERSICR50
;                    .SERSICN
;                    .AXISRATIO
;                    .ORIENTATION (deg -x of +y)
;                    .NDOF (# of deg of freedom)
;                    .CHISQUARED
;                    .FITPARAM[8]
;                    .PERROR[8]
;                    .COVARIANCE[8]
; OUTPUTS:
;   model - image of best fit model
; COMMENTS:
;   The input psf should be interpreted as an image of a delta
;    function source (pixel- and seeing-convolved)
;   If /onlyflux is set, then the inverse variances aren't used
;    on a pixel-by-pixel basis
;   If /onlyflux is set, only SERSICFLUX and SERSICFLUXIVAR are
;    changed in the "sersicfit" structure
; REVISION HISTORY:
;   10-Sep-2003  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function dsersic_model, fitparam

  common com_simple, image, invvar_fit, invvar_errors, nx, ny, psf, xcen, $
     ycen, oldfitparam, parinfo, oldmodel, simple, fluxivar

  ;; we have to guarantee we don't fall out, since mpfit does not
  use_fitparam=fitparam
  for i=0L, n_elements(fitparam)-1L do $
     if(parinfo[i].limited[0]) then $
        use_fitparam[i]=use_fitparam[i] > parinfo[i].limits[0]
  for i=0L, n_elements(fitparam)-1L do $
     if(parinfo[i].limited[1]) then $
        use_fitparam[i]=use_fitparam[i] < parinfo[i].limits[1]

  ;; get profile
  model=dfakegal(nx=nx,ny=ny,xcen=use_fitparam[2],ycen=use_fitparam[3], $
                 ba=use_fitparam[6],phi0=use_fitparam[7], $
                 r50=exp(use_fitparam[4]), sersicn=use_fitparam[5], $
                 flux=1., simple=simple)

  ;; convolve with seeing
  if(n_elements(psf) gt 1) then model=convolve(model,psf)

  ;; set flux linearly
  use_fitparam[0]=total((image-use_fitparam[1])*model*invvar_fit)/ $
                  total(model^2*invvar_fit)

  ;; set the inverse variance of the flux
  iok= where(invvar_errors gt 0, nok)
  if(nok gt 0) then begin
     fluxivar= (total(model[iok]^2*invvar_fit[iok],/double))^2/ $
               total(model[iok]^2*invvar_fit[iok]^2/invvar_errors[iok], /double)
  endif else begin
     fluxivar=0.
  endelse
  
  ;; apply flux and sky to model
  model=model*use_fitparam[0]+use_fitparam[1]
  fitparam[0]=use_fitparam[0]

  return, model

end
;
function dsersic_func, fitparam

  common com_simple

; calculate model
  model=dsersic_model(fitparam)

; return residuals

  return, reform(((model-image)*sqrt(invvar_fit)),n_elements(model))

end
;
pro dsersic,in_image,in_invvar,xcen=in_xcen,ycen=in_ycen,psf=in_psf, $
            sersicfit=sersicfit,model=model, reinit=reinit, $
            fixcenter=fixcenter,fixsky=fixsky, nofit=nofit, $
            simple=in_simple, axisymmetric=axisymmetric, $
            onlyflux=onlyflux

  if(n_params() lt 1) then begin
     doc_library, 'dsersic'
     return
  endif

  common com_simple

  ;; defaults, etc.
  nx=(size(in_image,/dim))[0]
  ny=(size(in_image,/dim))[1]
  if(n_elements(in_invvar) eq 0) then in_invvar=fltarr(nx,ny)+1.
  if(n_elements(in_xcen) eq 0) then in_xcen=float(nx/2L)
  if(n_elements(in_ycen) eq 0) then in_ycen=float(ny/2L)
  if(n_elements(in_psf) eq 0) then in_psf=1
  if(n_elements(in_simple) gt 0) then simple=in_simple else simple=0
  image=in_image
  invvar_fit=in_invvar
  invvar_errors=invvar_fit
  psf=in_psf
  xcen=in_xcen
  ycen=in_ycen
  xcen_orig=xcen
  ycen_orig=ycen
  oldfitparam=0
  fixsky=keyword_set(fixsky)
  fixcen=keyword_set(fixcenter)
  axisymmetric=keyword_set(axisymmetric)

  ;; if /onlyflux is set, then we want to use a different
  ;; invvar for the fit (a uniform one) but use the original
  ;; one to estimate errors
  if(keyword_set(onlyflux)) then begin
     igd= where(invvar_errors gt 0, ngd)
     if(ngd gt 0) then $
        ivarmed= median(invvar_errors[igd]) $
     else $
        ivarmed= 1.
     invvar_fit= float(invvar_errors gt 0.)*ivarmed
  endif

  ;; set initialization arbitrarily
  if(n_tags(sersicfit) eq 0 OR keyword_set(reinit)) then begin
     sersicfit={sky:0., $     
                xcen:xcen, $   
                ycen:ycen, $
                sersicflux:total(image), $     
                sersicflux_ivar:0., $
                sersicr50:20., $     
                sersicn:4., $     
                axisratio:0.5, $    
                orientation:45., $
                ndof:0L, $
                chisquared:0., $
                fitparam: fltarr(8), $
                perror:   fltarr(8), $
                covariance:fltarr(8,8)}
  endif
  if(keyword_set(axisymmetric)) then sersicfit.axisratio=1.

  ;; if inverse variance is zero everywhere, bomb
  if(total(invvar_errors) eq 0) then begin
     sersicfit.sersicflux=0.
     sersicfit.sersicr50=0.
     sersicfit.sersicn=0.
     sersicfit.axisratio=0.
     sersicfit.orientation=0.
     model= image*0.
     return
  endif

  ;; set up parinfo for mpfit
  str1 = {value:0D,fixed:1B,limited:[1B,1B],limits:[0D,1D], $
          step:1D0, mpside:0}
  parinfo = replicate(str1,8)
  parinfo.step= $
     [    1.0,    1E-1,    0.2,    0.2,  0.02, 0.01, 0.01,     1.0]
  parinfo.limited[0]= $
     [      0,       0,      1,      1,     1,    1,    1,       1]
  parinfo.limited[1]= $
     [      0,       0,      1,      1,     1,    1,    1,       1]
  parinfo.limits[0]=  $
     [     0.,  -1000.,     -1.,     -1., -1.20,  0.5, 0.15,    0.00]
  parinfo.limits[1]=  $
     [     1.,   1000.,     nx,     ny,  6.00,  6., 1.00,  360.00]
  parinfo.fixed=      $
     [      1,  fixsky, fixcen, fixcen,     0,    0,    $
            axisymmetric, axisymmetric]
  parinfo.value=      [sersicfit.sersicflux, $
                       sersicfit.sky, $
                       sersicfit.xcen, $
                       sersicfit.ycen, $
                       alog(sersicfit.sersicr50), $
                       sersicfit.sersicn, $
                       sersicfit.axisratio, $
                       sersicfit.orientation]

  if(NOT fixcen) then begin
     parinfo.value[2]= (parinfo.value[2] > parinfo[2].limits[0])<parinfo[2].limits[1]
     parinfo.value[2]= (parinfo.value[2] > parinfo[2].limits[0])<parinfo[2].limits[1]
     parinfo.value[3]= (parinfo.value[3] > parinfo[3].limits[0])<parinfo[3].limits[1]
     parinfo.value[3]= (parinfo.value[3] > parinfo[3].limits[0])<parinfo[3].limits[1]
  endif

  if(keyword_set(onlyflux) eq 0) then begin 

     ;; search starting from two possible orientations
     chisquared=fltarr(2)
     parinfo0=parinfo
     parinfo0[6].value=parinfo[6].value
     parinfo0[7].value=45.
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

     ;; take better version
     if(chisquared[0] le chisquared[1]) then begin
        fitparam=fitparam0
        covar=covar0
        perror=perror0
     endif else begin
        fitparam=fitparam1
        covar=covar1
        perror=perror1
     endelse

     chisquared=total(dsersic_func(fitparam)^2)

     ;; construct output
     model=dsersic_model(fitparam)
     sersicfit.sersicflux=    fitparam[0]
     sersicfit.sersicflux_ivar=    fluxivar ;; from common block
     sersicfit.sky=           fitparam[1]
     sersicfit.xcen=          fitparam[2]
     sersicfit.ycen=          fitparam[3]
     sersicfit.sersicr50=     exp(fitparam[4])
     sersicfit.sersicn=       fitparam[5]
     sersicfit.axisratio=     fitparam[6]
     sersicfit.orientation=   fitparam[7]
     sersicfit.ndof=          n_elements(model)-total(parinfo.fixed EQ 0)
     sersicfit.chisquared=    chisquared
     sersicfit.fitparam=      fitparam
     sersicfit.perror=        perror
     sersicfit.covariance=    covar

     help,/st,sersicfit

  endif else begin
     ;; if /onlyflux set, only fit flux
     fitparam=[sersicfit.sersicflux, $
               sersicfit.sky, $
               sersicfit.xcen, $
               sersicfit.ycen, $
               alog(sersicfit.sersicr50), $
               sersicfit.sersicn, $
               sersicfit.axisratio, $
               sersicfit.orientation]
     model=dsersic_model(fitparam)
     sersicfit.sersicflux= fitparam[0]
     sersicfit.sersicflux_ivar= fluxivar ;; from common block
  endelse

end
