pro test_8112

common com_dr8_examples, run

rootdir= '/global/data/scr/mb144/dr8_examples'
setenv, 'PHOTO_SKY=/global/data/scr/mb144/sky'

names=[ 'testsky3', 'testsky2', 'testsky1']

ra= [23.772, 23.72807, 23.43134]
     
dec= [  30.884, 30.46762, 30.294]

size= [0.1, 0.1, 0.1]

if(n_elements(run) eq 0) then begin
    window_read, flist=flist
    ikeep= where(flist.rerun eq '301' and flist.run ne 1473)
    run= (uniqtag(flist[ikeep], 'run')).run
endif

for i=2, n_elements(ra)-1L do begin
    subdir= rootdir+'/'+names[i]
    prefix= names[i]
    
    spawn, /nosh, ['mkdir', '-p' ,subdir]
    cd, subdir
    
    smosaic_make, ra[i], dec[i], size[i], size[i], $
      prefix=prefix, noclobber=noclobber, /ivarout, $
      minscore=0.5, /ignoreframesstatus, /processed, rerun=301, $
      /global, run=run, /dropweights, filter=[1,2,3]
    
    if(NOT keyword_set(scales)) then scales=[4., 5., 6.]*0.3
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
