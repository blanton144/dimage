;+
; NAME:
;   fls_sky
; PURPOSE:
;   make images of Spitzer FLS
; CALLING SEQUENCE:
;   fls_sky
; REVISION HISTORY:
;   25-Oct-2007 MRB, NYU
;-
;------------------------------------------------------------------------------
pro fls_sky

sz=1.
runs=[1336,1339,1356, 1359]
rerun=137

sdss_sky_patches, sz, runs=runs, rerun=rerun, ra=ra, dec=dec 

cd, '/global/data/sdss/fls_sky'
for i=0L, n_elements(ra)-1L do begin
    smosaic_dimage, ra[i], dec[i], sz=sz, /sub, /raw, /nocl, $
      run=runs, satvalue=30., scales=[6.,6.,6.], /jpg
endfor

end
;------------------------------------------------------------------------------
