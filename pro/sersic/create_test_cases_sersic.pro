;+
; NAME:
;   create_test_cases_sersic
; PURPOSE:
;   Run 1-component Sersic on images for 2-component Sersics
; CALLING SEQUENCE:
;   create_test_cases_sersic, filebase, nn
; INPUTS:
;   filebase - basename for each file
; REVISION HISTORY:
;   19-May-2014  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro create_test_cases_sersic, filebase, nn

if(keyword_set(psf) eq 0) then begin
    npsf=61L
    psf= fltarr(npsf, npsf)
    pcen= float(npsf/2L)
    xx=findgen(npsf)#replicate(1.,npsf)
    yy=transpose(findgen(npsf)#replicate(1.,npsf))
    r2= ((xx-pcen)^2+(yy-pcen)^2)
    amp= [0.62, 0.28, 0.10]
    sigma= [1.12, 2.12, 4.55]
    for i=0L,n_elements(amp)-1L do $
      psf= psf+amp[i]*exp(-0.5*r2/sigma[i]^2)/(2.*!DPI*sigma[i]^2)
endif

for i=0L, nn-1L do begin
    filename= filebase+'-'+strtrim(string(i),2)+'.fits'
    image= mrdfits(filename)
    measure= mrdfits(filebase+'-nsa-'+strtrim(string(i),2)+'.fits',1)
    dsersic, image, xcen=measure.xcen, ycen=measure.ycen, sersic=sersic, $
      model=model, psf=psf, /fixsky, /fixcenter
    mwrfits, sersic, filebase+'-sersic-'+strtrim(string(i),2)+'.fits', /create
    mwrfits, model, filebase+'-sersic-'+strtrim(string(i),2)+'.fits'
endfor

end
