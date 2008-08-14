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
pro lowz_dexplore, indx, sdss=sdss

common com_lowz_dexplore, lowz

if(NOT keyword_set(sample)) then sample='dr6'
if(NOT keyword_set(start)) then start=0L

if(n_elements(indx) gt 1) then begin
    for i=0L, n_elements(indx)-1L do $
      lowz_dexplore, indx[i], sdss=sdss
    return
endif

if(n_tags(lowz) eq 0) then $
  lowz=gz_mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits', 1)

rootdir=getenv('DATA')+'/lowz-sdss'

isort=lindgen(n_elements(lowz))
iexclude=lowz_iexclude()

subdir=image_subdir(lowz[isort[indx]].ra, lowz[isort[indx]].dec, $
                    prefix=prefix, rootdir=rootdir)

print, subdir

if(file_test(subdir)) then begin
    cd, subdir
    if(keyword_set(sdss)) then $
      display_object, lowz[isort[indx]].object_position
    dexplore, /cen, /hidestars, /nogalex
endif else begin
    splog, 'no such dir: '+subdir
endelse

end
