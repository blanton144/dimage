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
pro atlas_dimages, seed=seed, st=st, nd=nd, clobber=clobber

  window_read, flist=flist
  ikeep= where(flist.rerun eq '301' and flist.run ne 1473)
  run= (uniqtag(flist[ikeep], 'run')).run
  
  atlas=gz_mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits', 1)
  
  rootdir=atlas_rootdir(sample=sample)
  
  if(NOT keyword_set(st)) then st=0L
  if(NOT keyword_set(nd)) then nd=n_elements(atlas)-1L
  for i=st, nd do begin
     help,i
     subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir=rootdir)
     
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
