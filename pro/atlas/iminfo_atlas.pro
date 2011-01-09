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

flist= mrdfits(getenv('PHOTO_RESOLVE')+'/window_flist.fits',1)
unif= mrdfits(getenv('PHOTO_RESOLVE')+'/window_unified.fits',1)

;; check what field, if any, it is in

tmp_iminfo= sdss_findimage(atlas.ra, atlas.dec, rerun=301, /best)

;; add score to structure
iminfo0= create_struct(tmp_iminfo[0], 'score', 0.)
iminfo= replicate(iminfo0, n_elements(tmp_iminfo))
struct_assign, tmp_iminfo, iminfo

;; find score of each field
isdss= where(iminfo.run gt 0, nsdss)
if(nsdss gt 0) then begin
   iminfo[isdss].score= sdss_score(iminfo[isdss].run, iminfo[isdss].camcol, $
                                   iminfo[isdss].field, $
                                   rerun=iminfo[isdss].rerun, $
                                   /ignoreframesstatus)
endif

mwrfits, iminfo, getenv('DIMAGE_DIR')+'/data/atlas/atlas_iminfo.fits', /create

end
