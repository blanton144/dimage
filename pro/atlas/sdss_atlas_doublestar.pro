;+
; NAME:
;   sdss_atlas_doublestar
; PURPOSE:
;   For objects classified as stars, check if they are double
; CALLING SEQUENCE:
;   sdss_atlas_doublestar
; COMMENTS:
;   Reads from 
;      $DIMAGE_DIR/data/atlas/sdss/specTrim-dr8.fits
;   Writes to 
;      $DIMAGE_DIR/data/atlas/sdss/doubleStar-dr8.fits
; REVISION HISTORY:
;   31-Jul-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro sdss_atlas_doublestar

trim=hogg_mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/sdss/specTrim-dr8.fits', $
                  1, nrow=28800)

;; if it is classified spectroscopically as a star
isstar= strmatch(trim.class, 'STAR*') gt 0 
istar= where(isstar, nstar)
if(nstar gt 0) then begin
    double=is_doublestar(trim[istar].run, $
                         trim[istar].camcol, $
                         trim[istar].field, $
                         trim[istar].id, $
                         rerun=replicate(301, n_elements(trim)))
endif

end
