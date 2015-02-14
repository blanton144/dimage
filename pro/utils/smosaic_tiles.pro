;+
; NAME:
;   smosaic_tiles
; PURPOSE:
;   make tiles from list
; CALLING SEQUENCE:
;   smosaic_tiles, filename
; REVISION HISTORY:
;   16-Jan-2015  MRB, NYU
;-
;------------------------------------------------------------------------------
pro smosaic_tiles, filebase

list= mrdfits(filebase+'-tiles.fits', 1)

window_read, flist=flist
ikeep= where(flist.rerun eq '301' and flist.run ne 1473)
run= (uniqtag(flist[ikeep], 'run')).run

for i=0L, n_elements(list)-1L do begin
    prefix=filebase+'-'+strtrim(string(list[i].itile),2)
    smosaic_make, list[i].ra, list[i].dec, list.size, list.size, $
      prefix=prefix, noclobber=noclobber, /ivarout, /dontcrash, $
      minscore=0.5, /ignoreframesstatus, /processed, rerun=301, $
      /global, run=run, /dropweights, pixscale=0.396/3600., $
      filter=2
    spawn, /nosh, ['fits2tiff', '--input='+prefix+'.fits.gz', $
                   '--output='+prefix+'.png']
endfor

end
