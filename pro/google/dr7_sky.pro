;+
; NAME:
;   dr7_sky
; PURPOSE:
;   make images for the DR7 sky, northern galactic cap
; CALLING SEQUENCE:
;   fls_sky
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
;------------------------------------------------------------------------------
pro dr7_sky

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

cd, '/global/data/sdss/fls_sky'
for i=0L, n_elements(ra)-1L do begin
    smosaic_dimage, ra[i], dec[i], sz=sz, /sub, /raw, /nocl, $
      run=runs, satvalue=30., scales=[6.,6.,6.], /jpg
endfor

end
;------------------------------------------------------------------------------
