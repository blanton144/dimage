;+
; NAME:
;   create_test_cases
; PURPOSE:
;   Create a set of test cases for 2-component Sersics
; CALLING SEQUENCE:
;   create_test_cases, filebase, size, flux, r50, nn [, noise=] 
; INPUTS:
;   filebase - [N] basename for each file
;   size - [N] size of each image
;   flux - [N,2] flux of each component of each image
;   r50 - [N] size of each component of each image
;   nn - [N] Sersic index of each component of each image
;   phi - [N] position angle of component
;   ba - [N] axis ratio of component
; OPTIONAL INPUTS:
;   noise - noise in each pixel of each image (default 0.03) 
; COMMENTS:
;   Outputs [filebase]-[i].fits for i=0 to N-1. 
; REVISION HISTORY:
;   19-May-2014  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro create_test_cases, filebase, size, flux, r50, nn, phi, ba, $
                       xoffset, yoffset, noise=noise, $
                       psf=psf, noclobber=noclobber

if(keyword_set(noise) eq 0) then $
  noise=0.03

flux=reform(flux, n_elements(size), 2)
r50=reform(r50, n_elements(size), 2)
nn=reform(nn, n_elements(size), 2)
phi=reform(phi, n_elements(size), 2)
ba=reform(ba, n_elements(size), 2)

for i=0L, n_elements(size)-1L do begin
    filename= filebase+'-'+strtrim(string(i),2)+'.fits'

    if(file_test(filename) eq 0 or $
       keyword_set(noclobber) eq 0) then begin
        
        image= fltarr(size[i], size[i])
        xcen= (size[i]-1.)/2.+xoffset[i]
        ycen= (size[i]-1.)/2.+yoffset[i]
        
        im1= dfakegal(sersicn=nn[i,0], r50=r50[i,0], flux=flux[i,0], $
                      nx=size[i], ny=size[i], xcen=xcen, ycen=ycen, $
                      ba=ba[i,0], phi0=phi[i,0])
        im2= dfakegal(sersicn=nn[i,1], r50=r50[i,1], flux=flux[i,1], $
                      nx=size[i], ny=size[i], xcen=xcen, ycen=ycen, $
                      ba=ba[i,1], phi0=phi[i,1])
        
        image= im1+im2
        
        if(keyword_set(psf)) then $
          image= convolve(image, psf)
        
        image= image+randomn(seed, size[i], size[i])*noise
        
        mwrfits, image, filename, /create

        dmeasure, image, measure=measure, xcen=xcen, ycen=ycen
        mwrfits, measure, filebase+'-nsa-'+strtrim(string(i),2)+'.fits', /create
    endif

endfor

end
