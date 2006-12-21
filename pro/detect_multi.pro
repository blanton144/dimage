;+
; NAME:
;   detect_multi
; PURPOSE:
;   detect objects in multi-band image of bright object
; CALLING SEQUENCE:
;   detect_multi, base, imfile [, /dbset, /hand ]
; INPUTS:
;   base - base name for output
;   imfiles - array of FITS files with images in HDU 0
; OPTIONAL KEYWORDS:
;   /dbset - use old settings and psf (so you can set by hand)
;   /hand - will prompt for star and galaxy positions
; COMMENTS:
;   Assumes a sky-subtracted image in HDU 0
;   Works better if ivars supplied in HDU 1
;   Finds objects, selects largest one to deblend 
;   Outputs (assuming imfile is 'base.fits' or 'base.fits.gz'):
;     base-dbset.fits - settings, locations of stars and gals, etc
;     base-bpsf.fits - "basic" PSF estimate
;     base-pcat.fits - locations of parents in full image
;     base-parents.fits - in HDUs 2N+1 and 2N+2, imagse and ivars of parents
;     base-[parent]-atlas.fits - images of children of biggest parent
;     base-[parent].tar.gz - tar file with JPGs, etc
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro detect_multi, base, imfiles, dbset=dbset, hand=hand, ref=ref, sky=sky, $
                  noclobber=noclobber, glim=glim, all=all

if(NOT keyword_set(ref)) then ref=0
if(NOT keyword_set(glim)) then glim=20.
if(NOT keyword_set(gsmooth)) then gsmooth=5.

if(NOT keyword_set(dbset)) then begin
    dbset={base:base, $
           gsmooth:gsmooth, $
           glim:glim, $
           saddle:5.} 
endif else begin
    dbset=mrdfits(base+'-dbset.fits', 1)
endelse

;; get parents (creates pcat, pimage, parents files)
dparents_multi, base, imfiles, sky=sky, noclobber=noclobber

;; read in parents and look for closest object to center
hdr=headfits(base+'-pimage.fits',ext=0)
;;nx=long(sxpar(hdr, 'NAXIS1'))
;;ny=long(sxpar(hdr, 'NAXIS2'))
pcat=mrdfits(base+'-pcat.fits',1)
;;distance=sqrt((pcat.xc-nx*0.5)^2+ $
              ;;(pcat.yc-ny*0.5)^2)
;;mdist=min(distance, imdist)
;;dbset.parent=imdist

;; fit for psf (creates bpsf and vpsf files)
nim=n_elements(imfiles)
for k=0L, nim-1L do $
  dfitpsf, imfiles[k], noclobber=noclobber

for k=0L, nim-1L do begin
    bimfile=(stregex(imfiles[k], '(.*)\.fits.*', /sub, /extr))[1]
    if(n_tags(psfs) eq 0) then $
      psfs=dpsfread(bimfile+'-vpsf.fits') $
    else $
      psfs=[psfs, dpsfread(bimfile+'-vpsf.fits')]
endfor

if(keyword_set(all)) then begin
    for iparent=0L, n_elements(pcat)-1L do begin
        psfs.xst= pcat[iparent].xst
        psfs.yst= pcat[iparent].yst
        dchildren_multi, dbset.base, iparent, psfs=psfs, $
          ref=ref, gsmooth=dbset.gsmooth, glim=dbset.glim, hand=hand
    endfor
endif

dcombine_multi, dbset.base

mwrfits, dbset, base+'-dbset.fits', /create

;;dhtmlpage, dbset.base, dbset.parent, /install

end
;------------------------------------------------------------------------------
