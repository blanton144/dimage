;+
; NAME:
;   iminfo_atlas
; PURPOSE:
;   Get SDSS imaging coverage of all combined atlas positions
; CALLING SEQUENCE:
;   iminfo_atlas
; COMMENTS:
;   Reads in the file:
;      $DIMAGE_DIR/data/atlas/atlas_combine.fits
;   Outputs the file:
;      $DIMAGE_DIR/data/atlas/atlas_iminfo.fits
; REVISION HISTORY:
;   15-Aug-2010  MRB, NYU
;-
;------------------------------------------------------------------------------
pro iminfo_atlas

atlas=mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_combine.fits',1)

;; keep only things within SDSS
iminfo= sdss_findimage(atlas.ra, atlas.dec, rerun=301, /best)

mwrfits, iminfo, getenv('DIMAGE_DIR')+'/data/atlas/atlas_iminfo.fits', /create

end
