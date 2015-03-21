;+
; NAME:
;   make_wise_psfs
; PURPOSE:
;   Create "typical" WISE PSFs
; CALLING SEQUENCE:
;   make_wise_psfs
; OUTPUTS:
;   Writes in $DIMAGE_DIR/data/wise:
;     psf-w1.fits
;     psf-w2.fits
;     psf-w3.fits
;     psf-w4.fits
; COMMENTS:
;  Relies on Aaron Meisner's WISE product
; REVISION HISTORY:
;   2015-Mar-14 - Mike Blanton
;----------------------------------------------------------------------
pro make_wise_psfs

for i=1L, 4L do begin
    par1 = psf_par_struc(/allsky, band=i)
    psf1 = wise_psf_cutout(par1.crpix, par1.crpix, /bright, $
                           /allsky, band=i)
    npsf= (size(psf1, /dim))[0]
    st= npsf/2L-30L
    nd= npsf/2L+30L
    psf_w= psf1[st:nd, st:nd]
    mwrfits, psf_w, getenv('DIMAGE_DIR')+'/data/psf/psf-w'+$
      strtrim(string(i),2)+'.fits', /create
endfor

end
