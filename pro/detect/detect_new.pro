;+
; NAME:
;   detect_new
; PURPOSE:
;   detect objects in multi-band, multi-res images 
; CALLING SEQUENCE:
;   detect_new, base, imfiles
; INPUTS:
;   base - base name for output
;   imfiles - [Nband] array of FITS files with images in HDU 0
; OPTIONAL INPUTS:
;   ref - integer indicating which imfile is the "reference"
;   sky - if set, subtracts a median smoothed sky with this box size
;         (in arcsec)
;   plim - number of sigma for parent detection (default 5)
;   glim - number of sigma for a galaxy detection (default 20)
;   slim - number of sigma for a point source detection (default 10)
;   gsmooth - smoothing scale for galaxies (default 5)
;   single - if set, only process this parent number
;   puse - [Nband] 0 or 1, whether to use band to find parents
;   pbuffer - fractional buffer to add around parents (default 0.1)
; OPTIONAL KEYWORDS:
;   /sdss - assume ugriz
;   /gsdss - assume ugrizNF (N and F from GALEX)
;   /all - process all parents
;   /hand - for children, put results in "hand" subdir (used by dexplore)
;   /noclobber - do not overwrite previously created files
;   /noparentclobber - do not overwrite previously PARENT files
;   /pset - use "parent" settings from base-pset.fits file
;   /aset - use "child" settings from base-aset.fits file
;   /sgset - get locations of stars and galaxies from base-sgset.fits file
; COMMENTS:
;   When calling automatically, it is best not to use the /hand
;     option; reserve that for when dexplore calls this function and you
;     have set the parameters by hand.
;   Assumes that multi-res images are APPROXIMATELY overlapping
;     (within a pixel or two)
;   Assumes a sky-subtracted image in HDU 0
;   Works better if ivars supplied in HDU 1
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro detect_new, base, imfiles, sdss=sdss, gsdss=gsdss, $
                pset=pset, hand=hand, ref=ref, sky=sky, $
                noclobber=noclobber, glim=glim, slim=slim, all=all, $
                single=single, aset=aset, sgset=sgset, gsmooth=gsmooth, $
                puse=puse, center=center, seed=seed0, nogalex=nogalex, $
                gsaddle=gsaddle, nostarim=nostarim, novpsf=novpsf, $
                noparentclobber=noparentclobber, plim=plim, sersic=sersic, $
                pbuffer=pbuffer, maxnstar=maxnstar
  
if(NOT keyword_set(seed0)) then seed0=11L
if(NOT keyword_set(ref)) then ref=0
if(NOT keyword_set(glim)) then glim=20.
if(NOT keyword_set(slim)) then slim=10.
if(NOT keyword_set(gsaddle)) then gsaddle=20.
if(NOT keyword_set(gsmooth)) then gsmooth=3.

;; default to use base name same as directory name
if(NOT keyword_set(base)) then begin
   spawn, 'pwd', cwd
   base=file_basename(cwd)
endif

;; need to specify image files somehow
if(NOT keyword_set(imfiles)) then begin
   if(keyword_set(sdss) gt 0) then begin
      ;; 
      imfiles=base+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
      puse=[1,1,1,1,1]
      dopsf=[1,1,1,1,1]
      tuse=[1,1,2,3,4]
      ref=2
   endif else if (keyword_set(gsdss) gt 0) then begin
      imfiles=base+'-'+['u', 'g', 'r', 'i', 'z', 'nd', 'fd']+'.fits.gz'
      puse=[1,1,1,1,1,0,0]
      dopsf=[1,1,1,1,1,1,0]
      tuse=[1,1,2,3,4,1,1]
      ref=2
   endif else begin
      message, 'Must specify imfiles in some way!'
   endelse
endif

;; create pset structure, or if /pset set use stored one
if(NOT keyword_set(pset)) then begin
    pset={base:base, $
          ref:ref, $
          puse:puse, $
          dopsf:dopsf}
endif else begin
    pset=gz_mrdfits(base+'-pset.fits', 1, /silent)
    if(n_tags(pset) eq 0) then $
       message, '/pset set, but no [base]-pset.fits file available'
endelse

;; get parents (creates pcat, pimage, parents files)
seed_parents=seed0
nc= keyword_set(noclobber) OR keyword_set(noparentclobber)
dparents, base, imfiles, sky=sky, noclobber=nc, ref=pset.ref, $
          puse=pset.puse, seed=seed_parents, cenonly=center, plim=plim, $
          pbuffer=pbuffer

;; read in parents 
hdr=gz_headfits(base+'-pimage.fits',ext=0)
pcat=gz_mrdfits(base+'-pcat.fits',1)

;; fit for psf (creates bpsf and vpsf files)
nim=n_elements(imfiles)
seed_psf=seed0+1L+lindgen(nim)
for k=0L, nim-1L do $
   if(pset.dopsf[k]) then $
      dfitpsf, imfiles[k], noclobber=noclobber, natlas=natlas, seed=seed_psf[k], $
               novpsf=novpsf

;;
for k=0L, nim-1L do begin
   bimfile=(stregex(imfiles[k], '(.*)\.fits.*', /sub, /extr))[1]
   tmp_psf=dpsfread(bimfile+'-vpsf.fits') 
   if(n_tags(tmp_psf) eq 0) then $
      tmp_psf=dummy_psf(41L,10000L, 10000L)
   if(n_tags(psfs) eq 0) then $
      psfs=tmp_psf $
   else $
      psfs=[psfs, tmp_psf]
endfor

if(keyword_set(center)) then begin
    pim=gz_mrdfits(base+'-pimage.fits')
    nx=(size(pim,/dim))[0]
    ny=(size(pim,/dim))[1]
    single=pim[nx/2L, ny/2L]
endif

if(n_elements(single) gt 0) then begin
    if(single ge 0) then begin
        psfs.xst= pcat[single].xst
        psfs.yst= pcat[single].yst
        dchildren, base, single, psfs=psfs, $
          ref=ref, gsmooth=gsmooth, glim=glim, aset=aset, hand=hand, $
          sgset=sgset, puse=pset.puse, tuse=tuse, $
          gsaddle=gsaddle, nostarim=nostarim, slim=slim, $
          noclobber=noclobber, sersic=sersic, maxnstar=maxnstar
        heap_gc
    endif
endif

mwrfits, pset, base+'-pset.fits', /create

end
;------------------------------------------------------------------------------
