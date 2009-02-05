;+
; NAME:
;   patch_png
; PURPOSE:
;   Make a Google-style PNG from a given patch
; CALLING SEQUENCE:
;   patch_png, prefix [, patchpath=, pngpath=]
; INPUTS:
;   prefix - prefix name (assumes prefix-[gri].fits.gz all exist)
; OPTIONAL INPUTS:
;   patchpath - path to inputs (default ".")
;   pngpath - path to outputs (default ".")
; COMMENTS:
;   Write outputs to:
;     pngpath/prefix.png (PNG file with image)
;     pngpath/prefix_wcs.fits (empty FITS with WCS header)
;     pngpath/prefix_mask.tif (TIFF form 0 or 1 mask)
;   In conformance to Google Sky, these are flipped images.
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
pro patch_png, prefix, patchpath=patchpath, pngpath=pngpath

if(NOT keyword_set(patchpath)) then patchpath='.'
if(NOT keyword_set(pngpath)) then pngpath='.'

;; read in images
iim=mrdfits(patchpath+'/'+prefix+'-i.fits.gz',0)
iim= reverse(iim, 2)
rim=mrdfits(patchpath+'/'+prefix+'-r.fits.gz',0,hdr)
rim= reverse(rim, 2)
gim=mrdfits(patchpath+'/'+prefix+'-g.fits.gz',0)
gim= reverse(gim, 2)

;; write out mask as TIFF
maskname= pngpath+'/'+prefix+'_mask.tif'
mask= iim ne 0. OR rim ne 0. AND gim ne 0.
rmask= reverse(mask, 2)
write_tiff, maskname, mask, bits_per_sample=1, compression=2
spawn, 'gzip -fv '+maskname

;; write out PNG
pngname=pngpath+'/'+prefix+'.png'
smosaic_make_jpg_scales, scales,nonlinearity
nw_rgb_make, iim, rim, gim, scales=scales, $
             nonlinearity=nonlinearity, quality=100, $
             /png, name=pngname
spawn, 'gzip -fv '+pngname

;; write out hdr to an other empty fits file
wcsname= pngpath+'/'+prefix+'_wcs.fits'
mwrfits, 0, wcsname, hdr, /create

end

