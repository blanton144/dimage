;+
; NAME:
;   dr7_sky_patch
; PURPOSE:
;   make patch list for the DR7 sky, northern galactic cap
; CALLING SEQUENCE:
;   dr7_sky_patch
; COMMENTS:
;   Makes a file at:
;    $GOOGLE_DIR/sky-patches.fits
;   That has a table with the columns:
;      .RA 
;      .DEC
;      .SIZE
;      .PROCESSID
;      .DONE
;   for each patch.
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
;------------------------------------------------------------------------------
pro dr7_sky_patches

;; make 1 deg images
sz=1.

;; get the list of runs to use
runs=sdss_runlist(rerun=[137, 161])
ikeep= where(runs.stripe ge 5 and runs.stripe le 41, nkeep)
if(nkeep eq 0) then $
  message, 'no runs!'
runs=runs[ikeep]

;; make the full list of patches
sdss_sky_patches, sz, runs=runs.run, rerun=runs.rerun, ra=ra, dec=dec 

;; create structure
patch1= {RA:0.D, $
         DEC:0.D, $
         SIZE:0.D, $
         PROCESSID:-1L, $
         DONE:0}
patch=replicate(patch1, n_elements(ra))
patch.ra= ra
patch.dec= dec
patch.size= sz

outfile= getenv('GOOGLE_DIR')+'/sky-patches.fits'
mwrfits, patch, outfile, /create

end
;------------------------------------------------------------------------------
