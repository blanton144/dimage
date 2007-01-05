;+
; NAME:
;   detect_multi
; PURPOSE:
;   detect objects in multi-band image of bright object
; CALLING SEQUENCE:
;   detect_multi, base, imfile [, /aset, /pset, /hand ]
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
pro detect_multi, base, imfiles, pset=pset, hand=hand, ref=ref, sky=sky, $
                  noclobber=noclobber, glim=glim, all=all, single=single, $
                  aset=aset, sgset=sgset

if(NOT keyword_set(ref)) then ref=0
if(NOT keyword_set(glim)) then glim=20.
if(NOT keyword_set(gsmooth)) then gsmooth=5.

if(NOT keyword_set(pset)) then begin
    pset={base:base, $
          ref:ref}
endif else begin
    pset=mrdfits(base+'-pset.fits', 1)
endelse

;; get parents (creates pcat, pimage, parents files)
dparents_multi, base, imfiles, sky=sky, noclobber=noclobber, $
  ref=pset.ref

;; read in parents and look for closest object to center
hdr=headfits(base+'-pimage.fits',ext=0)
pcat=mrdfits(base+'-pcat.fits',1)

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
        dchildren_multi, base, iparent, psfs=psfs, $
          ref=pset.ref, gsmooth=gsmooth, glim=glim, aset=aset, $
          sgset=sgset
    endfor
endif

if(n_elements(single) gt 0) then begin
    psfs.xst= pcat[single].xst
    psfs.yst= pcat[single].yst
    dchildren_multi, base, single, psfs=psfs, $
      ref=ref, gsmooth=gsmooth, glim=glim, aset=aset, hand=hand, $
      sgset=sgset
endif

dcombine_multi, base, hand=hand

mwrfits, pset, base+'-pset.fits', /create

;;dhtmlpage, dbset.base, dbset.parent, /install

end
;------------------------------------------------------------------------------
