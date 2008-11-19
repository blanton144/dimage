;+
; NAME:
;   lowz_gzip
; PURPOSE:
;   go to each lowz, make an image, and analyze it
; CALLING SEQUENCE:
;   lowz_dimage [, sample=]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro lowz_gzip, sample=sample, start=start, nd=nd

common com_lowz_dlinks, lowz

noclobber=keyword_set(clobber) eq 0

if(NOT keyword_set(sample)) then sample='dr6'
if(NOT keyword_set(start)) then start=0L

if(n_tags(lowz) eq 0) then $
  lowz=gz_mrdfits(getenv('VAGC_REDUX')+'/lowz/lowz_plus_ned.fits', 1)

lowzdir=getenv('VAGC_REDUX')+'/lowz/'
rootdir=getenv('DATA')+'/lowz-sdss'

if(NOT keyword_set(nd)) then nd=n_elements(lowz)-1L

for i=start, nd do begin
    splog, i
    
    subdir=image_subdir(lowz[i].ra, lowz[i].dec, $
                        prefix=prefix, rootdir=rootdir, $
                        subname='dimages')
    
    if(file_test(subdir)) then $
      spawn, 'gzip -vfr '+subdir
endfor

end
