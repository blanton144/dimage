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
pro dr7_sky_patch

;; make 1 deg images
sz=1.

;; get the list of runs to use
runs=sdss_runlist(rerun=[137, 161, 648])
ikeep= where(runs.stripe ge 5 and runs.stripe le 41, nkeep)
if(nkeep eq 0) then $
  message, 'no runs!'
runs=runs[ikeep]

;; make the full list of 
sdss_sky_patches, sz, runs=runs.run, rerun=runs.rerun, ra=ra, dec=dec 

cd, '/global/data/sdss/dr7_sky'
for i=0L, n_elements(ra)-1L do begin
    smosaic_dimage, ra[i], dec[i], sz=sz, /sub, /raw, /nocl, $
      run=runs, satvalue=30., scales=[6.,6.,6.], /jpg
endfor

end
;------------------------------------------------------------------------------
