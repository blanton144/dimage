;+
; NAME:
;   sdss_starcheck
; PURPOSE:
;   For a given image, get aperture photometry around SDSS stars
; CALLING SEQUENCE:
;   sdss_starcheck, image, hdr [, filter=, flux=, sdssflux=, x=, y= ]
; INPUTS:
;   image - [N, M] image in nanomaggies/pix 
;   hdr - WCS header for image
; OPTIONAL INPUTS:
;   filter - SDSS filter, either as 0-4 or 'u', 'g', 'r', 'i', or 'z'
;            (default 'r')
; OUTPUTS:
;   flux - aperture flux (within 7.3 arcsec)
;   sdssflux - aperture flux from SDSS (aperflux[6,filter])
;   x, y - position of SDSS stars in image
; COMMENTS:
;   We choose stars with no other star within 15 arcsec
;   Images are assumed to be 0.396 arcsec/pix
; REVISION HISTORY:
;   2-Mar-2009  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro sdss_starcheck, image, hdr, filter=filter, flux=flux, $
                    sdssflux=sdssflux, x=x, y=y

if(NOT keyword_set(filter)) then filter='r'

pixscale= 0.396/3600.
isorad= 15./3600.
edge=isorad/pixscale
aperture= 7.359/3600./pixscale

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]
ifilter= filternum(filter)

;; find center
xcen= nx/2.
ycen= nx/2.
xyad, hdr, xcen, ycen, racen, deccen

;; get stars in the area
radius= sqrt(float(nx/0.5)^2+float(ny/0.5)^2)*pixscale
obj= sdss_sweep_circle(racen, deccen, radius, type='star')
if(n_tags(obj) eq 0) then begin
    splog, 'No SDSS stars!'
    return
endif

;; take only isolated stars
ing= spheregroup(obj.ra, obj.dec, isorad, mult=mult)
ikeep=where(mult[ing] eq 1, nkeep)
if(nkeep eq 0) then begin
    splog, 'No isolated SDSS stars!'
    return
endif
obj=obj[ikeep]

;; now keep only those within image and far from edge
adxy, hdr, obj.ra, obj.dec, tmpx, tmpy
ikeep=where(tmpx gt edge AND tmpx lt nx-1.-edge AND $
            tmpy gt edge AND tmpy lt ny-1.-edge, nkeep)
if(nkeep eq 0) then begin
    splog, 'No isolated SDSS stars away from edge!'
    return
endif
obj=obj[ikeep]

;; finally, get the fluxes of those 
adxy, hdr, obj.ra, obj.dec, x, y
flux=fltarr(n_elements(obj))
for i=0L, n_elements(obj)-1L do begin
    flux[i]=djs_phot(x[i], y[i], aperture, 0, image, calg='none', salg='none')
endfor

;; report SDSS fluxes
sdssflux= transpose(obj.psfflux[ifilter])

return

end
