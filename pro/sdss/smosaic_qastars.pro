;+
; NAME:
;   smosaic_qastars
; PURPOSE:
;   For a given image, find SDSS stars suitable for QA
; CALLING SEQUENCE:
;   obj=smosaic_qastars(image, hdr)
; INPUTS:
;   image - [N, M] image in nanomaggies/pix 
;   hdr - WCS header for image
; OUTPUTS:
;   obj - [P] "star" datasweep structure
; COMMENTS:
;   We choose stars with no other star within 15 arcsec
;   Images are assumed to be 0.396 arcsec/pix
; REVISION HISTORY:
;   2-Mar-2009  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
function smosaic_qastars, image, hdr

pixscale= 0.396/3600.
isorad= 15./3600.
edge=isorad/pixscale

nx=(size(image,/dim))[0]
ny=(size(image,/dim))[1]

;; find center
xcen= nx/2.
ycen= nx/2.
xyad, hdr, xcen, ycen, racen, deccen

;; get stars in the area
radius= sqrt(float(nx/0.5)^2+float(ny/0.5)^2)*pixscale
obj= sdss_sweep_circle(racen, deccen, radius, type='star')
if(n_tags(obj) eq 0) then begin
    splog, 'No SDSS stars!'
    return, 0
endif

;; take only isolated stars
ing= spheregroup(obj.ra, obj.dec, isorad, mult=mult)
ikeep=where(mult[ing] eq 1, nkeep)
if(nkeep eq 0) then begin
    splog, 'No isolated SDSS stars!'
    return, 0
endif
obj=obj[ikeep]

;; now keep only those within image and far from edge
adxy, hdr, obj.ra, obj.dec, tmpx, tmpy
ikeep=where(tmpx gt edge AND tmpx lt nx-1.-edge AND $
            tmpy gt edge AND tmpy lt ny-1.-edge, nkeep)
if(nkeep eq 0) then begin
    splog, 'No isolated SDSS stars away from edge!'
    return, 0
endif
obj=obj[ikeep]

;; now trim away saturated things and bad deblends and such
indx= sdss_selectobj(obj, count=count, /trim)
if(count eq 0) then begin
    splog, 'No good isolated SDSS stars away from edge!'
    return, 0
endif
obj=obj[indx]

return, obj

end
