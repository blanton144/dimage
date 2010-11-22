;+
; NAME:
;   dparents_atlas
; PURPOSE:
;   detect parents in NASA-Sloan Atlas images
; CALLING SEQUENCE:
;   detect_parents
; OPTIONAL KEYWORDS:
;   /galex - assume ugrizNF (N and F from GALEX)
;   /nolobber - do not overwrite previously PARENT files
; COMMENTS:
;   Requires dparents_atlas.pro to have been run
;   Assumes input file names of the form:
;      [base]-[ugriz].fits.gz
;      [base]-pset.fits
;   Outputs:
;      [base]-bpsf.fits - basic (single-fit) PSF
;   Doesn't track PSF variation across field
; REVISION HISTORY:
;   11-Jan-2006  Written by Blanton, NYU
;-
;------------------------------------------------------------------------------
pro dpsf_atlas, galex=galex, noclobber=noclobber
  
if(NOT keyword_set(seed0)) then seed0=11L ;; random seed
if(NOT keyword_set(plim)) then plim=10. ;; for detecting parents

;; default to use base name same as directory name
spawn, 'pwd', cwd
base=(file_basename(cwd))[0]

;; read in pset
pset= mrdfits(base+'-pset.fits',1)
imfiles=pset.imfiles

;; fit for psf (creates bpsf and vpsf files)
nim=n_elements(imfiles)
seed_psf=seed0+1L+lindgen(nim)
for k=0L, nim-1L do $
  if(pset.dopsf[k]) then $
  dfitpsf_atlas, imfiles[k], natlas=natlas, $
                 seed=seed_psf[k]

end
;------------------------------------------------------------------------------
