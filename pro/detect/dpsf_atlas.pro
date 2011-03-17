;+
; NAME:
;   dparents_atlas
; PURPOSE:
;   detect parents in NASA-Sloan Atlas images
; CALLING SEQUENCE:
;   detect_parents
; OPTIONAL KEYWORDS:
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
pro dpsf_atlas, noclobber=noclobber
  
if(NOT keyword_set(seed0)) then seed0=11L ;; random seed
if(NOT keyword_set(plim)) then plim=10. ;; for detecting parents

;; default to use base name same as directory name
spawn, 'pwd', cwd
base=(file_basename(cwd))[0]

;; read in pset
pset= gz_mrdfits(base+'-pset.fits',1)
imfiles=strtrim(pset.imfiles,2)

;; fit for psf (creates bpsf and vpsf files)
nim=n_elements(imfiles)
seed_psf=seed0+1L+lindgen(nim)
for k=0L, nim-1L do begin
    mm= strmid(imfiles[k], strlen(base))
    bname= (stregex(mm, '-(.*)\.fits.*', /sub, /extr))[1]
    psffile= base+'-'+bname+'-bpsf.fits'
    if(gz_file_test(psffile) eq 0 OR $
       keyword_set(noclobber) eq 0) then begin
        if(pset.dopsf[k]) then begin
            dfitpsf_atlas, imfiles[k], natlas=natlas, $
              seed=seed_psf[k] 
        endif else begin
            file_copy, getenv('DIMAGE_DIR')+'/data/psf/psf-'+bname+'.fits', $
              psffile, /over
        endelse
    endif
endfor

end
;------------------------------------------------------------------------------
