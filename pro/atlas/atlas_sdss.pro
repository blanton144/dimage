;+
; NAME:
;   atlas_sdss
; PURPOSE:
;   Trim specList file to possibly atlas-related spectra
; CALLING SEQUENCE:
;   atlas_sdss
; COMMENTS:
;   Reprocesses the file:
;      $DIMAGE_DIR/data/atlas/sdss/specList-dr8.fits
;   into 
;      $DIMAGE_DIR/data/atlas/sdss_atlas.fits
; REVISION HISTORY:
;   31-Mar-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_sdss

list=hogg_mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/sdss/specList-dr8.fits', $
                  1, nrow=28800)

sdss_flux2lups, list.modelflux, model, /noivar
rmag= model[2,*]
sdss_flux2lups, list.psfflux, psf, /noivar
pmm= psf[2,*]-rmag

;; check low redshift
lowz= list.z lt 0.055 and list.z ne 0.

;; if it is classified as an M-star
mstar= strmatch(list.class, 'STAR*') gt 0 AND $
  strmatch(list.subclass, 'M*') gt 0 

;; if it is extended
pmmlimit= 0.1+exp((14.-rmag)*0.3)
extended= list.objc_type eq 3 AND $
  pmm gt pmmlimit

;; if it is classified spectroscopically as a star
isstar= strmatch(list.class, 'STAR*') gt 0 

;; check zwarnings
badflags= 'SKY LITTLE_COVERAGE SMALL_DELTA_CHI2 NEGATIVE_MODEL '+ $
  'Z_FITLIMIT NEGATIVE_EMISSION UNPLUGGED'
zbad= (list.zwarning and sdss_flagval('ZWARNING', badflags)) gt 0

;; trim back to things which SOME classifications deems
;; not stars (unless they are an M-star, and are unique,
;; and are low redshift, and aren't bad spectra
itrim= where(list.specprimary gt 0 and $
             lowz gt 0 and $
             mstar eq 0 and $
             zbad eq 0 and $
             (extended gt 0 OR isstar eq 0), ntrim)
trim= list[itrim]

;; fix RA, Dec for non-matches
inon= where(trim.ra eq 0 and trim.dec eq 0, nnon)
if(nnon gt 0) then begin
   trim[inon].ra= trim[inon].plug_ra
   trim[inon].dec= trim[inon].plug_dec
endif

;; finally, actually check for position doubles 
;; (these survive SPECPRIMARY above because the 
;; matches can be to the same galaxy).
ing= spheregroup(trim.ra, trim.dec, 2./3600., firstg=firstg)
ii=where(firstg ge 0)
trim=trim[firstg[ii]]

mwrfits, trim, getenv('DIMAGE_DIR')+'/data/atlas/sdss_atlas.fits', $
  /create

end
