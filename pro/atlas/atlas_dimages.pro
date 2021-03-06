;+
; NAME:
;   atlas_dimages
; PURPOSE:
;   Make the atlas images for SDSS ugriz 
; CALLING SEQUENCE:
;   atlas_dimages [, version=, st=, nd=, /clobber]
; OPTIONAL INPUTS:
;   version - version of atlas
;   st - Starting NSAID to process
;   nd - Ending NSAID to process
; OPTIONAL KEYWORDS:
;   /clobber - overwrite existing data
; COMMENTS:
;   Uses smosaic_make.
;   Ignores data marked as unphotometric or otherwise bad, but still
;     includes unprocessed frames. That is, a photo pipeline failure
;     from SDSS doesn't exclude a frame. 
;   Ignores run 1473.
;   Hardcodes rerun 301
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_dimages, st=st, nd=nd, clobber=clobber, version=version

  window_read, flist=flist
  ikeep= where(flist.rerun eq '301' and flist.run ne 1473)
  run= (uniqtag(flist[ikeep], 'run')).run
  
  rootdir= atlas_rootdir(version=version)
  atlas=gz_mrdfits(rootdir+'/catalogs/atlas.fits', 1)
  
  if(NOT keyword_set(st)) then st=0L
  if(NOT keyword_set(nd)) then nd=n_elements(atlas)-1L
  for i=st, nd do begin
     help,i
     subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir=rootdir+'/detect', $
                        subname='sdss')
     
     spawn, /nosh, ['mkdir', '-p' ,subdir]
     cd, subdir

     runsmosaic= keyword_set(clobber) ne 0
     bands=['u', 'g', 'r', 'i', 'z']
     for iband=0L, n_elements(bands)-1L do begin
        filename= prefix[0]+'-'+bands[iband]+'.fits'
        if(gz_file_test(filename) eq 0) then $
           runsmosaic=runsmosaic OR 1
     endfor
     
     help, runsmosaic
     
     if(runsmosaic) then $
        smosaic_make, atlas[i].ra, atlas[i].dec, atlas[i].size, atlas[i].size, $
                      prefix=prefix, noclobber=noclobber, /ivarout, /dontcrash, $
                      minscore=0.5, /ignoreframesstatus, /processed, rerun=301, $
                      /global, run=run, /dropweights

     runjpg=0
     filename=prefix+'.jpg'
     if(file_test(filename) eq 0 OR keyword_set(clobber) ne 0) then $
        runjpg=1
     
     if(runjpg) then begin
        scales=[4., 5., 6.]*0.9
        satvalue=30.
        nonlinearity=3.
        djs_rgb_make, prefix[0]+'-i.fits.gz', $
                      prefix[0]+'-r.fits.gz', $
                      prefix[0]+'-g.fits.gz', $
                      name=prefix+'.jpg', $
                      scales=scales, $
                      nonlinearity=nonlinearity, satvalue=satvalue, $
                      quality=100.
     endif
     
  endfor
  
end
