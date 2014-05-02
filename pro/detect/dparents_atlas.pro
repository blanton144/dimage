;+
; NAME:
;   dparents_atlas
; PURPOSE:
;   detect parents in NASA-Sloan Atlas images
; CALLING SEQUENCE:
;   detect_parents
; OPTIONAL KEYWORDS:
;   /galex - assume ugrizNF (N and F from GALEX)
;   /twomass - assume ugrizNFJHK 
;   /nolobber - do not overwrite previously PARENT files
; COMMENTS:
;   Detects parents; only outputs a parent that actually includes
;     the central pixel. 
;   Assumes input file names of the form:
;      [base]-[ugriz].fits.gz
;    where [base] is the current directory name. If /galex is set, 
;    include -nd and -fd images from GALEX too.
;   Assumes that the images are APPROXIMATELY overlapping
;     (within a pixel or two)
;   Assumes a sky-subtracted image in HDU 0
;   Works better if ivars supplied in HDU 1
;   Writes outputs to:
;      [base]-pset.fits 
;      [base]-#-pimage.fits - HDU0: full image with parent number in each pixel
;                            HDU1-N: individual band parent images
;                            (because the resolution might be
;                            different)
;      [base]-#-pcat.fits - image with parent number in each pixel
;      parents/[base]-parent-[parent].fits - multi-HDU file with
;                                            individual parents
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dparents_atlas, twomass=twomass, galex=galex, noclobber=noclobber
  
if(NOT keyword_set(seed0)) then seed0=11L ;; random seed
if(NOT keyword_set(ref)) then ref=2L ;; use r-band as reference
if(NOT keyword_set(plim)) then plim=10. ;; for detecting parents
if(NOT keyword_set(pbuffer)) then pbuffer=0.5 ;; for detecting parents

;; default to use base name same as directory name
spawn, 'pwd', cwd, /nosh
base=(file_basename(cwd))[0]

;; use SDSS images, plus GALEX
imfiles=base+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
puse=long([1,1,1,1,1])
dopsf=long([1,1,1,1,1])
ref=2L
if (keyword_set(galex) gt 0) then begin
    imfiles=base+'-'+['u', 'g', 'r', 'i', 'z', 'nd', 'fd']+'.fits.gz'
    puse=long([1,1,1,1,1,0,0])
    dopsf=long([1,1,1,1,1,0,0])
    ref=2L
endif 
if (keyword_set(twomass) gt 0) then begin
    imfiles=base+'-'+['u', 'g', 'r', 'i', 'z', 'nd', 'fd', 'J', 'H', 'K']+'.fits.gz'
    puse=long([1,1,1,1,1,0,0,0,0,0])
    dopsf=long([1,1,1,1,1,0,0,1,1,1])
    ref=2L
endif 

if(keyword_set(noclobber) eq 0 OR $
   gz_file_test(base+'-pset.fits') eq 0) then begin
    ;; create pset structure
    pset={base:base, $
          imfiles:imfiles, $
          ref:ref, $
          puse:puse, $
          dopsf:dopsf}
    dhdr= dimage_hdr()
    mwrfits, pset, base+'-pset.fits', dhdr, /create
endif else begin
    pset= gz_mrdfits(base+'-pset.fits',1)
endelse

;; get parents (creates pcat, pimage, parents files)
seed_parents=seed0
dparents, base, imfiles, noclobber=noclobber, ref=pset.ref, $
  puse=pset.puse, seed=seed_parents, /cenonly, plim=plim, $
  pbuffer=pbuffer


end
;------------------------------------------------------------------------------
