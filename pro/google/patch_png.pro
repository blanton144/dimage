;+
; NAME:
;   patch_png
; PURPOSE:
;   Make a Google-style PNG from a given patch
; CALLING SEQUENCE:
;   patch_png, prefix [, patchpath=, pngpath=, /clobber]
; INPUTS:
;   prefix - prefix name (assumes prefix-[gri].fits.gz all exist)
; OPTIONAL INPUTS:
;   patchpath - path to inputs (default ".")
;   pngpath - path to outputs (default ".")
; OPTIONAL KEYWORDS:
;   /clobber - if set, remake outputs even if they exist
; COMMENTS:
;   Write outputs to:
;     pngpath/prefix.png (PNG file with image)
;     pngpath/prefix_wcs.fits (empty FITS with WCS header)
;     pngpath/prefix_mask.tif (TIFF form 0 or 1 mask)
;   In conformance to Google Sky, these are flipped images.
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
pro patch_png, prefix, patchpath=patchpath, pngpath=pngpath, clobber=clobber

if(NOT keyword_set(patchpath)) then patchpath='.'
if(NOT keyword_set(pngpath)) then pngpath='.'

maskname= pngpath+'/'+prefix+'_mask.tif'
pngname=pngpath+'/'+prefix+'.png'
wcsname= pngpath+'/'+prefix+'_wcs.fits'

if(file_test(maskname) gt 0 AND $
   file_test(pngname) gt 0 AND $
   file_test(wcsname) gt 0 AND $
   keyword_set(clobber) eq 0) then begin
    splog, 'All PNG outputs exist already!'
    return
endif

;; read in images
iim=mrdfits(patchpath+'/'+prefix+'-i.fits.gz',0)
if(NOT keyword_set(iim)) then begin
    splog, 'No i-iimage!'
    return
endif

rim=mrdfits(patchpath+'/'+prefix+'-r.fits.gz',0,hdr)
if(NOT keyword_set(rim)) then begin
    splog, 'No r-iimage!'
    return
endif

gim=mrdfits(patchpath+'/'+prefix+'-g.fits.gz',0)
if(NOT keyword_set(gim)) then begin
    splog, 'No g-iimage!'
    return
endif

;; write out mask as TIFF
mask= iim ne 0. OR rim ne 0. AND gim ne 0.
mask= reverse(mask, 2)
write_tiff, maskname, mask, bits_per_sample=1, compression=2
mask=0
spawn, 'gzip -fv '+maskname

;; write out PNG
rescale= 0.4 ;; hardish
scales= rescale*[5., 6.5, 9.] ;; "normal"
nonlinearity= 2.25 ;; less than default nonlinearity
nw_rgb_make, iim, rim, gim, scales=scales, $
             nonlinearity=nonlinearity, $
             /png, name=pngname

;; write out hdr to an other empty fits file
mwrfits, 0, wcsname, hdr, /create

end

