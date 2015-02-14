;+
; NAME:
;   atlas_dimages
; PURPOSE:
;   make the atlas dimages
; CALLING SEQUENCE:
;   atlas_dimages [, seed= ]
; COMMENTS:
;   Requires tree dr8
;   Ignores run 1473.
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro smosaic_plate, plate, size

if(NOT keyword_set(size)) then size=3.

plans= yanny_readone(getenv('PLATELIST_DIR')+'/platePlans.par')
iplate=where(plans.plateid eq plate, nplate)
if(nplate eq 0) then begin
  print, 'No such plate: '+strtrim(string(plate),2)
  return
endif
ra= plans[iplate].racen
dec= plans[iplate].deccen
prefix= 'plate-'+strtrim(string(plate),2)

window_read, flist=flist
ikeep= where(flist.rerun eq '301' and flist.run ne 1473)
run= (uniqtag(flist[ikeep], 'run')).run
  
smosaic_make, ra, dec, size, size, $
  prefix=prefix, noclobber=noclobber, /ivarout, /dontcrash, $
  minscore=0.5, /ignoreframesstatus, /processed, rerun=301, $
  /global, run=run, /dropweights, pixscale=0.349964/3600., $
  filter=2

spawn, /nosh, ['gzip', '-d', prefix+'.fits.gz']
spawn, /nosh, ['fits2tiff', '--input='+prefix+'.fits', $
               '--output='+prefix+'.png']

end
