;+
; NAME:
;   lowz_dread
; PURPOSE:
;   read information for a particular lowz image
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro lowz_dread, indx, image=image, ivar=ivar, measure=measure, psf=psf, $
                _EXTRA=extra_for_dreadcen

common com_lowz_dexplore, lowz

if(NOT keyword_set(sample)) then sample='dr6'
if(NOT keyword_set(start)) then start=0L

if(n_tags(lowz) eq 0) then $
  lowz=gz_mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits', 1)

rootdir=getenv('DATA')+'/lowz-sdss'

iexclude=lowz_iexclude()

subdir=image_subdir(lowz[indx].ra, lowz[indx].dec, $
                    prefix=prefix, rootdir=rootdir)

print, subdir

if(file_test(subdir)) then begin
    spawn, 'pwd', cwd
    cd, subdir
    dreadcen, image, ivar, measure=measure, psf=psf, _EXTRA=extra_for_dreadcen
    cd, cwd[0]
endif else begin
    splog, 'no such dir: '+subdir
endelse

end
