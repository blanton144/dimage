pro dr8_examples

common com_dr8_examples, run

rootdir= '/global/data/scr/mb144/dr8_examples'

names=[ 'm33']

ra= [23.4620417D]
     
dec= [30.6602222D]

if(n_elements(run) eq 0) then begin
    window_read, flist=flist
    ikeep= where(flist.rerun eq '301' and flist.run ne 1473)
    run= (uniqtag(flist[ikeep], 'run')).run
endif

for i=0, n_elements(ra)-1L do begin
    subdir= names[i]
    prefix= names[i]
    
    spawn, /nosh, ['mkdir', '-p' ,subdir]
    cd, subdir
    
    smosaic_make, ra[i], dec[i], 0.25, 0.25, $
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
