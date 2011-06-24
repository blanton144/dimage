;+
; NAME:
;   sample_dimages
; PURPOSE:
;   make a sample set of images for atlas for testing
; CALLING SEQUENCE:
;   sample_dimages [, seed= ]
; COMMENTS:
;   Requires tree dr8
;   Ignores run 1473.
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro sample_dimages, seed=seed, version=version

rootdir=atlas_rootdir(/sample, version=version)

  if(not keyword_set(seed)) then seed=-109L

  window_read, flist=flist
  ikeep= where(flist.rerun eq '301' and flist.run ne 1473)
  run= (uniqtag(flist[ikeep], 'run')).run

  atlas=gz_mrdfits(rootdir+'/catalogs/atlas.fits', 1)

  ibright= where(atlas.mag lt 15.5)
  atlas=atlas[ibright]

  indx= shuffle_indx(n_elements(atlas), num_sub=500, seed=seed)
  atlas=atlas[indx]

  mwrfits, atlas, rootdir+'/catalogs/atlas_sample.fits', /create
  
  for i=0, n_elements(atlas)-1L do begin
     subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir=rootdir)
     
     spawn, /nosh, ['mkdir', '-p' ,subdir]
     cd, subdir
 
     smosaic_make, atlas[i].ra, atlas[i].dec, atlas[i].size, atlas[i].size, $
                   prefix=prefix, noclobber=noclobber, /ivarout, /dontcrash, $
                   minscore=0.5, /ignoreframesstatus, /processed, rerun=301, $
                   /global, run=run, /dropweights

     if(NOT keyword_set(scales)) then scales=[4., 5., 6.]*0.9
     if(NOT keyword_set(satvalue)) then satvalue=30.
     if(NOT keyword_set(nonlinearity)) then nonlinearity=3.
     djs_rgb_make, prefix[0]+'-i.fits.gz', $
                   prefix[0]+'-r.fits.gz', $
                   prefix[0]+'-g.fits.gz', $
                   name=prefix+'.jpg', $
                   scales=scales, $
                   nonlinearity=nonlinearity, satvalue=satvalue, $
                   quality=100.
     
  endfor
  
end
