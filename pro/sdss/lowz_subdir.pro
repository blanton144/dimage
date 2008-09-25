;+
; NAME:
;   lowz_subdir
; PURPOSE:
;   go to each lowz, make an image, and analyze it
; CALLING SEQUENCE:
;   subdir= lowz_subdir(indx)
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
function lowz_subdir, indx

common com_lowz_dexplore, lowz

if(NOT keyword_set(sample)) then sample='dr6'

if(n_tags(lowz) eq 0) then $
  lowz=gz_mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits', 1)

rootdir=getenv('DATA')+'/lowz-sdss'

isort=lindgen(n_elements(lowz))

subdir=image_subdir(lowz[isort[indx]].ra, lowz[isort[indx]].dec, $
                    prefix=prefix, rootdir=rootdir)

return, subdir

end
