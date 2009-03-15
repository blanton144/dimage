;+
; NAME:
;   smosaic_qa
; PURPOSE:
;   Make qa file and plot for a smosiac'ed SDSS image
; CALLING SEQUENCE:
;   smosaic_qa, prefix [, path=, /localsky ]
; INPUTS:
;   prefix - prefix of file names (expect prefix-u.fits.gz ...)
; OPTIONAL INPUTS;
;   path - path to file [default '.']
; OPTIONAL KEYWORDS:
;   /localsky - subtract local sky first (256x256 pixel median smoothed)
; COMMENTS:
;   Reads in files from:
;     path/prefix-u.fits.gz
;     path/prefix-g.fits.gz
;     path/prefix-r.fits.gz
;     path/prefix-i.fits.gz
;     path/prefix-z.fits.gz
;   which it expects to be FITS images with valid WCS
;   headers, with a pixel scale of 0.396 arcsec. 
;   Writes out file:
;     ./prefix-qa.fits
;   with a structure with one element per star, with tags:
;     .SDSS[5] - SDSS aperflux[6,*] flux in each band
;     .SDSSIVAR[5] - SDSS aperflux[6,*] flux in each band
;     .FLUX[5] - our aperture flux in each band
;     .FLERR[5] - our aperture flux in each band
;     .X - X position in image
;     .Y - Y position in image
; REVISION HISTORY:
;   2-Mar-2009  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro smosaic_qa, prefix, path=path, localsky=localsky

if(keyword_set(path) eq 0) then path='.'

bands=['u', 'g', 'r', 'i', 'z']

qastr1={sdss:fltarr(5), $
        sdssivar:fltarr(5), $
        flux:fltarr(5), $
        flerr:fltarr(5), $
        x:0., $
        y:0.}

ifilter=2
image= mrdfits(path+'/'+prefix+'-'+bands[ifilter]+'.fits.gz',0, hdr)

obj=smosaic_qastars(image, hdr)
if(n_tags(obj) eq 0) then return

qastr=replicate(qastr1, n_elements(obj))
adxy, hdr, obj.ra, obj.dec, x, y
qastr.x=x
qastr.y=y

extraobj= sdss_readobjlist(inlist=obj, select_tags=['aperflux', $
                          'aperflux_ivar'])

qastr.sdss= reform(extraobj.aperflux[6,*], 5, n_elements(obj))
qastr.sdssivar= reform(extraobj.aperflux_ivar[6,*], 5, n_elements(obj))

for ifilter=0L, n_elements(bands)-1L do begin
    image= mrdfits(path+'/'+prefix+'-'+bands[ifilter]+'.fits.gz',0, hdr)
    if(keyword_set(localsky) gt 0) then begin
		  medsmooth= dmedsmooth(image, box=256)
      image= image-medsmooth
    endif
    smosaic_starcheck, image, hdr, obj, flux=flux, flerr=flerr, x=x, y=y
    qastr.flux[ifilter]=flux
    qastr.flerr[ifilter]=flerr
endfor

outfile= prefix+'-qa.fits'
if(keyword_set(localsky) gt 0) then $
  outfile= prefix+'-local-qa.fits'
mwrfits, qastr, outfile, /create

return
end
