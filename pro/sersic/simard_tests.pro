;+
; NAME:
;   simard_tests
; PURPOSE:
;   Use Simard catalog to define a set of test cases
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
pro simard_tests, filebase, noclobber=noclobber, sizeshuffle=sizeshuffle

seed=-79L

simorig= mrdfits(getenv('DIMAGE_DIR')+'/data/cats/simard-sdss-sn4.fits',1)
simgd= (simorig.rhlr gt 0. and $
        simorig.rg2d gt 0. and $
        simorig.re gt 0. and $
        simorig.rd gt 0. and $
        simorig.scale gt 0. and $
        simorig.rg2d lt 16.5)
isimgd= where(simgd, nsimgd)
indx= shuffle_indx(nsimgd, seed=seed, num_sub=10000L)
sim= simorig[isimgd[indx]]

if(keyword_set(sizeshuffle)) then begin
    sindx=shuffle_indx(n_elements(sim))
    oldscale= sim.rhlr/sim.scale
    newscale= sim[sindx].rhlr/sim[sindx].scale
    rescale=newscale/oldscale
    sim.rhlr= sim.rhlr*rescale
    sim.rchl_r= sim.rchl_r*rescale
    sim.re= sim.re*rescale
    sim.rd= sim.rd*rescale
endif
  
mwrfits, sim, 'sim-test.fits', /create

if(keyword_set(noise) eq 0) then $
  noise=0.03

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

;; set fluxes in nmgy
tflux= 10.^(0.4*(22.5-sim.rg2d))
fb= sim.__b_t_r
fd= 1.-fb
flux= fltarr(n_elements(sim), 2)
flux[*,0]= tflux*fb
flux[*,1]= tflux*fd

;; set r50 (in pixels!)
r50= fltarr(n_elements(sim), 2)
r50[*,0]= sim.re/0.396/sim.scale
r50[*,1]= 1.678*sim.rd/0.396/sim.scale

;; set Sersic index
nn= fltarr(n_elements(sim), 2)
nn[*,0]= 4.
nn[*,1]= 1.

;; set position angle
phi= fltarr(n_elements(sim), 2)
phi[*,0]= sim.phib
phi[*,1]= sim.phid

;; set axis ratio
ba= fltarr(n_elements(sim), 2)
ba[*,0]= 1.-sim.e
ba[*,1]= cos(sim.i*!DPI/180.)

size=lonarr(n_elements(sim))
for i=0L, n_elements(sim)-1L do begin
    size[i]= (max(r50[i,*]*20.)<2000L)>300L
endfor

xoff= randomu(seed, n_elements(sim))-0.5
yoff= randomu(seed, n_elements(sim))-0.5

create_test_cases, filebase, size, flux, r50, nn, phi, ba, xoff, yoff, psf=psf

end
