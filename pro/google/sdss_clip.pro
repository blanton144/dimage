;+
; NAME:
;   sdss_clip
; PURPOSE:
;   Clip out a region from the Google Sky SDSS tiles
; CALLING SEQUENCE:
;   image= sdss_clip(ra, dec, sz [, filter=, hdr=])
; INPUTS:
;   ra, dec - center of desired clip, J2000 deg
;   sz - size of clip desired (deg)
; COMMENTS:
;   Clips are always square.
;   They are created from just a single tile, so if they overlap an
;     edge the uncovered pixels are just set to zero
;   The tile picked is one whose center is closest to the desired
;     point.
;   They retain the WCS header of the original, but with the reference
;     pixel shifted (so the tangent point is the tangent point of the
;     original tile).
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
;------------------------------------------------------------------------------
function sdss_clip, ra, dec, sz, filter=filter, hdr=hdr

common com_sdss_clip, patch

if(n_elements(ra) ne 1 OR n_elements(dec) ne 1 or n_elements(sz) ne 1) then $
  message, 'RA, DEC, and Sz must all be set, and be scalars'

if(n_tags(patch) eq 0) then $
  patch= mrdfits(getenv('GOOGLE_DIR')+'/sky-patches.fits',1)
maxsize= max(patch.size)+sz

spherematch, ra, dec, patch.ra, patch.dec, maxsize, m1, m2, d12
if(m1[0] eq -1) then $
  return, 0

patchdir= image_subdir(patch[m2[0]].ra, patch[m2[0]].dec, $
                       root=getenv('GOOGLE_DIR'), subname='fits', $
                       prefix=prefix)
patchfile= patchdir+'/'+prefix+'-'+filter+'.fits.gz'

hdr= headfits(patchfile)
extast, hdr, ast

;; get y ranges
ad2xy, hdr, ra, dec, xcen, ycen
ad2xy, hdr, ra, dec+0.5*sz, xtmp, yhi
ad2xy, hdr, ra, dec-0.5*sz, xtmp, ylo

;; convert to integer
lxcen= long(xcen)
lycen= long(ycen)
lyhi= long(yhi)
lylo= long(ylo)

;; get x ranges
lxhi= lxcen+(lyhi-lycen)
lxlo= lxcen+(lylo-lycen)

;; bound to image
nxpatch= long(sxpar(hdr, 'NAXIS1'))
nypatch= long(sxpar(hdr, 'NAXIS2'))
lxhi=(lxhi>0)<(nxpatch-1)
lyhi=(lyhi>0)<(nypatch-1)
lxlo=(lxlo>0)<(nxpatch-1)
lylo=(lylo>0)<(nypatch-1)
if(lxhi le lxlo OR lyhi le lylo) then $
  return, 0

;; read patch files
image= mrdfits(patchfile, range=[lylo, lyhi])
image=image[lxlo:lxhi,*]

return, image

end
;------------------------------------------------------------------------------
