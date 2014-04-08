;+
; NAME:
;   dsersic_errors
; PURPOSE:
;   Using previous set of parameters, recalculate errors on Sersic fit
; CALLING SEQUENCE:
;   dsersic, image [, invvar, xcen=, ycen=, r50=, sersicn=,
;      axisratio=, orientation=, psf=, sersicfit=, $
;      model=, /reinit, /fixsky, /fixcenter, /simple, $
;      /axisymmetric, /onlyflux]
; INPUTS:
;   image - [nx,ny] input image
; OPTIONAL INPUTS:
;   invvar - [nx,ny] input inverse variance [default to unity everywhere]
;   xcen - center of image [default to nx/2L]
;   ycen - center of image [default to ny/2L]
;   r50 - half-light radius in pixels [default to 3.]
;   sersicn - Sersic index [default to 3.]
;   axisratio - b/a [default to 0.6]
;   orientation - position angle, degrees (x of y) [default to 90.]
;   psf - [nxpsf,nypsf] estimated psf [default to just pixel convolution]
;   /fixcenter - fix the center at the input xcen, ycen
;   /fixsky - fix the sky to zero
;   /axisymmetric - fix axis ratio to unity
;   /onlyflux - just fit for the flux, nothing else
;   /simple - just evaluate Sersic at each pixel, don't integrate it
; OUTPUTS:
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
;   Calls dsersic to refit (so answer *could* change) and reports
;     errors from that routine.
;   Useful for cases where the parameters were kept but the errors
;     not.
; REVISION HISTORY:
;   09-Jan-2014  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dsersic_errors,in_image,in_invvar,xcen=in_xcen,ycen=in_ycen,psf=in_psf, $
                   r50=in_r50, sersicn=in_sersicn, axisratio=in_axisratio, $
                   orientation= in_orientation, sersicfit=sersicfit,model=model, $
                   reinit=reinit, fixcenter=fixcenter,fixsky=fixsky, nofit=nofit, $
                   simple=in_simple, axisymmetric=axisymmetric, $
                   onlyflux=onlyflux

if(n_params() lt 1) then begin
    doc_library, 'dsersic_errors'
    return
endif

image=in_image
if(n_elements(in_invvar) gt 0) then $
  invvar=in_invvar
if(n_elements(in_xcen) gt 0) then $
  xcen=in_xcen $
else $
  xcen=(size(image, /dim))[0]/2.
if(n_elements(in_ycen) gt 0) then $
  ycen=in_ycen $
else $
  ycen=(size(image, /dim))[1]/2.
if(n_elements(in_psf) gt 0) then $
  psf=in_psf $
else $
  psf=0
if(n_elements(in_r50) gt 0) then $
  r50=in_r50 $
else $
  r50=3.
if(n_elements(in_sersicn) gt 0) then $
  sersicn=in_sersicn $
else $
  sersicn=3.
if(n_elements(in_axisratio) gt 0) then $
  axisratio=in_axisratio $
else $
  axisratio=0.6
if(n_elements(in_orientation) gt 0) then $
  orientation=in_orientation $
else $
  orientation=45.

sersicfit={sky:0., $     
           xcen:xcen, $   
           ycen:ycen, $
           sersicflux:total(image), $     
           sersicflux_ivar:0., $
           sersicr50:r50, $     
           sersicn:sersicn, $     
           axisratio:axisratio, $    
           orientation:orientation, $
           ndof:0L, $
           chisquared:0., $
           fitparam: fltarr(8), $
           perror:   fltarr(8), $
           covariance:fltarr(8,8)}

dsersic, image,invvar,xcen=xcen,ycen=ycen,psf=psf, $
  sersicfit=sersicfit,model=model, reinit=reinit, $
  fixcenter=fixcenter,fixsky=fixsky, nofit=nofit, $
  simple=in_simple, axisymmetric=axisymmetric, $
  onlyflux=onlyflux

end
