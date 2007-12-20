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
pro lowz_dexplore, indx, sort=sort, ran=ran

common com_lowz_dexplore, cand

if(n_tags(cand) eq 0) then $
  cand=mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_candidates.dr7.fits', 1)

lowzdir=getenv('VAGC_REDUX')+'/lowz/'

rootdir=lowzdir

isort=lindgen(n_elements(cand))
if(keyword_set(sort)) then $
  isort=sort(cand.mag)

if(keyword_set(ran)) then begin
    ii=lindgen(137)
    iin=where(long(cand[isort[ii]].ra/15.) eq 11L, nin)
    help,iin
    indx=ii[iin[shuffle_indx(nin, num_sub=1)]]
endif

subdir=image_subdir(cand[isort[indx]].ra, cand[isort[indx]].dec, $
                    prefix=prefix, rootdir=rootdir)

print, subdir

cd, subdir
dexplore

end
