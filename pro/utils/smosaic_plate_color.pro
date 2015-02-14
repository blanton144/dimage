;+
; NAME:
;   smosaic_plate_color
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
pro smosaic_plate_color, plate, size

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

if(0) then begin
window_read, flist=flist
ikeep= where(flist.rerun eq '301' and flist.run ne 1473)
run= (uniqtag(flist[ikeep], 'run')).run
  
smosaic_make, ra, dec, size, size, $
  prefix=prefix, noclobber=noclobber, /ivarout, /dontcrash, $
  minscore=0.5, /ignoreframesstatus, /processed, rerun=301, $
  /global, run=run, /dropweights, pixscale=0.349964/3600., $
  filter=[1,2,3]
endif

post= 'irg'
impost= ['i','r','g']
scales= [3.6, 4.5, 5.4]
satvalue= 30.

rfile= prefix+'-'+impost[0]+'.fits'
gfile= prefix+'-'+impost[1]+'.fits'
bfile= prefix+'-'+impost[2]+'.fits'
rim= temporary(mrdfits(rfile, 0L, rhdr))
gim= temporary(mrdfits(gfile, 0L, ghdr))
bim= temporary(mrdfits(bfile, 0L, bhdr))

fullfile= prefix+'-'+post+'.jpg'

djs_rgb_make, rim, gim, bim, $
  scales=scales, name=fullfile, $
  nonlinearity=nonlinearity, satvalue=satvalue, $
  quality=100

end
