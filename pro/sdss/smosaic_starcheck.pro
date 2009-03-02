;+
; NAME:
;   smosaic_starcheck
; PURPOSE:
;   For a given image, get aperture photometry around known stars
; CALLING SEQUENCE:
;   smosaic_starcheck, image, hdr, obj [, flux=, flerr=, x=, y=]
; INPUTS:
;   image - [N, M] image in nanomaggies/pix 
;   hdr - WCS header for image
;   obj - [P] "star" datasweep structure (only necessary tags
;         are .RA, .DEC)
; OUTPUTS:
;   flux - aperture flux (within 7.3 arcsec)
;   flerr - error in aperture flux 
;   x, y - position of SDSS stars in image
; COMMENTS:
;   Aperture photometry is 7.359 arcsec radius
;   Images are assumed to be 0.396 arcsec/pix
; REVISION HISTORY:
;   2-Mar-2009  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro smosaic_starcheck, image, hdr, obj, flux=flux, flerr=flerr, x=x, y=y

pixscale= 0.396/3600.
aperture= 7.359/3600./pixscale

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

;; make ivar
ivar=fltarr(nx,ny)
ii=where(image ne 0., nii)
if(nii eq 0) then begin
    splog, 'Image is all zeros!'
    return
endif  
sig=dsigma(image, sp=5)
ivar[ii]=1./sig^2

;; finally, get the fluxes of known stars 
adxy, hdr, obj.ra, obj.dec, x, y
flux=fltarr(n_elements(obj))
flerr=fltarr(n_elements(obj))
for i=0L, n_elements(obj)-1L do begin
    flux[i]=djs_phot(x[i], y[i], aperture, 0, image, ivar, calg='none', $
                     salg='none', flerr=tmp_flerr)
    flerr[i]=tmp_flerr
endfor

return

end
