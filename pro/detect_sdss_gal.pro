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
pro detect_sdss_gal, base, imfiles, pset=pset, hand=hand, ref=ref, sky=sky, $
                     noclobber=noclobber, glim=glim, all=all, single=single, $
                     aset=aset, sgset=sgset, gsmooth=gsmooth

if(NOT keyword_set(ref)) then ref=2
if(NOT keyword_set(glim)) then glim=8.
if(NOT keyword_set(plim)) then plim=10.
if(NOT keyword_set(gsmooth)) then gsmooth=8.

if(NOT keyword_set(base)) then begin
    spawn, 'pwd', cwd
    words=strsplit(cwd[0], '/',/extr)
    base=words[n_elements(words)-1]
endif
imfiles=base+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'

extrs=stregex(base, '.*-(......)-(.)-(....)-(.*)', /sub, /extr)
sdss={run:long(extrs[1]), $
      camcol:long(extrs[2]), $
      field:long(extrs[3]), $
      filter:'', $
      rerun:long(extrs[4])}

if(NOT keyword_set(pset)) then begin
    pset={base:base, $
          ref:ref}
endif else begin
    pset=mrdfits(base+'-pset.fits', 1)
endelse

;; get parents (creates pcat, pimage, parents files)
dparents_sdss_gal, base, imfiles, sky=sky, noclobber=noclobber, $
  ref=pset.ref, sdss=sdss

;; read in parents and look for closest object to center
hdr=headfits(base+'-pimage.fits',ext=0)
pcat=mrdfits(base+'-pcat.fits',1)

if(keyword_set(all)) then begin
    for iparent=0L, n_elements(pcat)-1L do begin
        dchildren_multi, base, iparent, psfs=psfs, $
          ref=pset.ref, gsmooth=gsmooth, glim=glim, aset=aset, $
          sgset=sgset, starlimit=500., sizelimit=100, plim=plim, $
          sdss=sdss
    endfor
endif

if(n_elements(single) gt 0) then begin
    psfs.xst= pcat[single].xst
    psfs.yst= pcat[single].yst
    dchildren_multi, base, single, psfs=psfs, $
      ref=ref, gsmooth=gsmooth, glim=glim, aset=aset, hand=hand, $
      sgset=sgset, plim=plim, sdss=sdss
endif

dcombine_multi, base, hand=hand

mwrfits, pset, base+'-pset.fits', /create

if(keyword_set(all)) then fit_lsb, base

;;dhtmlpage, dbset.base, dbset.parent, /install

end
;------------------------------------------------------------------------------
