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
                  noclobber=noclobber

if(NOT keyword_set(ref)) then ref=0

if(NOT keyword_set(dbset)) then begin
    dbset={base:base, $
           gsmooth:2., $
           glim:5., $
           saddle:5., $
           parent:-1L, $
           xstars:fltarr(128), $
           ystars:fltarr(128), $
           rastars:fltarr(128), $
           decstars:fltarr(128), $
           nstars:0L, $
           xgals:fltarr(128), $
           ygals:fltarr(128), $
           ragals:fltarr(128), $
           decgals:fltarr(128), $
           ngals:0L}
endif

;; get parents (creates pcat, pimage, parents files)
dparents_multi, base, imfiles, sky=sky, noclobber=noclobber

;; read in parents and look for closest object to center
hdr=headfits(base+'-pimage.fits',ext=0)
nx=long(sxpar(hdr, 'NAXIS1'))
ny=long(sxpar(hdr, 'NAXIS2'))
pcat=mrdfits(base+'-pcat.fits',1)
distance=sqrt((pcat.xc-nx*0.5)^2+ $
              (pcat.yc-ny*0.5)^2)
mdist=min(distance, imdist)
dbset.parent=imdist

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

if(dbset.nstars gt 0) then begin 
    xstars=dbset.xstars[0:dbset.nstars-1]
    ystars=dbset.ystars[0:dbset.nstars-1]
endif
if(dbset.ngals gt 0) then begin 
    xgals=dbset.xgals[0:dbset.ngals-1]
    ygals=dbset.ygals[0:dbset.ngals-1]
endif
psfs.xst= pcat[dbset.parent].xst
psfs.yst= pcat[dbset.parent].yst
dchildren_multi, dbset.base, dbset.parent, psfs=psfs, $
  ref=ref, gsmooth=dbset.gsmooth, xstars=xstars, ystars=ystars, $
  xgals=xgals, ygals=ygals, hand=hand, nstars=nstars, ngals=ngals

dbset.nstars=nstars
dbset.ngals=ngals
if(dbset.nstars gt 0) then begin
    dbset.xstars[0:dbset.nstars-1]=xstars
    dbset.ystars[0:dbset.nstars-1]=ystars
endif
if(dbset.ngals gt 0) then begin
    dbset.xgals[0:dbset.ngals-1]=xgals
    dbset.ygals[0:dbset.ngals-1]=ygals
endif
  
mwrfits, dbset, base+'-dbset.fits', /create

dhtmlpage, dbset.base, dbset.parent, /install

end
;------------------------------------------------------------------------------
