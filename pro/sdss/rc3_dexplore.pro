;+
; NAME:
;   lowz_dimage
; PURPOSE:
;   go to each lowz, make an image, and analyze it
; CALLING SEQUENCE:
;   lowz_dimage [, sample=]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro rc3_dexplore, indx

common com_rc3_dexplore, rc3

if(n_tags(rc3) eq 0) then $
  rc3=mrdfits(getenv('VAGC_REDUX')+'/rc3/rc3_sdssish.fits', 1)

lowzdir=getenv('VAGC_REDUX')+'/lowz/'

rootdir=lowzdir

subdir=image_subdir(rc3[indx].ra, rc3[indx].dec, $
                    prefix=prefix, rootdir=rootdir)

print, subdir

cd, subdir
dexplore

end
