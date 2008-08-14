;+
; NAME:
;   dmeasure
; PURPOSE:
;   measure a deblended image
; CALLING SEQUENCE:
;   dmeasure, image, ivar [, xcen=, ycen=, measure=, /check ]
; INPUTS:
;   image - [nx,ny] input image
; OPTIONAL INPUTS:
;   invvar - [nx,ny] input inverse variance [default to unity everywhere]
;   xcen - center of image [default to maximum of image]
;   ycen - center of image [default to maximum of image]
;   cpetrorad - fixed petrosian radius to assume
; OPTIONAL KEYWORDS:
;   /check - display image and overplot checks
; OUTPUTS:
;   measure - parameters of measurements
; REVISION HISTORY:
;   10-Aug-2008  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dmeasure, image, ivar, xcen=in_xcen, ycen=in_ycen, measure=measure, $
              check=check, cpetrorad=cpetrorad

common com_dmeasure, cache

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[0]

if(NOT keyword_set(ivar)) then begin
    sigma= dsigma(image, sp=4)
    ivar= fltarr(nx, ny)+1./sigma^2
endif

if(n_elements(in_xcen) eq 0 OR n_elements(in_ycen) eq 0) then begin
    dpeaks, image, xcen=xcen, ycen=ycen, maxnpeaks=1L, /refine
endif else begin
    xcen= in_xcen
    ycen= in_ycen
endelse

measure= {xcen:xcen[0], $
          ycen:ycen[0], $
          nprof:0L, $
          profmean:fltarr(15), $
          profmean_ivar:fltarr(15), $
          qstokes:fltarr(15), $
          ustokes:fltarr(15), $
          bastokes:fltarr(15), $
          phistokes:fltarr(15), $
          petroflux:0., $
          petrorad:0., $
          petror90:0., $
          petror50:0., $
          ba50:0., $
          phi50:0., $
          ba90:0., $
          phi90:0., $
          asymmetry:0., $
          clumpy:0., $
          dflags:0L}

if(total(image) eq 0.) then begin
    splog, 'zero image'
    measure.dflags= measure.dflags OR $
      dimage_flagval('DFLAGS', 'ZERO_IMAGE') OR $
      dimage_flagval('DFLAGS', 'ZERO_PROFILE') 
    return
endif

;; get profmean
extract_profmean, image, long([xcen, ycen]), tmp_profmean, $
  tmp_profmean_ivar, nprof=tmp_nprof, profradius=profradius, cache=cache, $
  qstokes=tmp_qstokes, ustokes=tmp_ustokes

mmp= minmax(tmp_profmean)
if(mmp[0] eq 0. AND mmp[1] eq 0.) then begin
    splog, 'zero profile'
    measure.dflags= measure.dflags OR $
      dimage_flagval('DFLAGS', 'ZERO_PROFILE')
    return
endif

measure.nprof= tmp_nprof
measure.profmean= tmp_profmean
measure.profmean_ivar= tmp_profmean_ivar
measure.qstokes= tmp_qstokes
measure.ustokes= tmp_ustokes
qu_to_baphi, measure.qstokes, measure.ustokes, tmp_bastokes, tmp_phistokes
measure.bastokes= tmp_bastokes
measure.phistokes= tmp_phistokes

;; measure petrosian radii
dpetro, measure.nprof, measure.profmean, petrorad=tmp_petrorad, $
  petror50= tmp_petror50, petror90= tmp_petror90, petroflux= tmp_petroflux, $
  cpetrorad= cpetrorad
measure.petrorad= tmp_petrorad
measure.petror50= tmp_petror50
measure.petror90= tmp_petror90
measure.petroflux= tmp_petroflux

;; evaluate BA and PHI at 50 and 90% light radii
measure.ba50= interpol(measure.bastokes, profradius, measure.petror50)
measure.phi50= interpol(measure.phistokes, profradius, measure.petror50)
measure.ba90= interpol(measure.bastokes, profradius, measure.petror90)
measure.phi90= interpol(measure.phistokes, profradius, measure.petror90)

;; find asymmetry
dasymmetry, image, ivar, measure.xcen, measure.ycen, measure.petror90, $
  axcen=axcen, aycen=aycen, asymmetry=tmp_asymmetry, ba=measure.ba90, $
  phi=measure.phi90, dflags=dflags
measure.dflags= measure.dflags OR dflags
measure.asymmetry= tmp_asymmetry

;; find clumpiness
dflags=0
smooth=(0.3*measure.petror50)>2.
dclumpy, image, ivar, measure.xcen, measure.ycen, $
  [smooth, measure.petror90], smooth, clumpy=tmp_clumpy, $
  dflags=dflags
measure.dflags= measure.dflags OR dflags
measure.clumpy= tmp_clumpy

if(keyword_set(check)) then begin
    dmeasure_check, image, ivar, measure=measure
endif

end
