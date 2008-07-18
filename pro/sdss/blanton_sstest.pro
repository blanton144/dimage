pro blanton_sstest

sstest=mrdfits(getenv('DIMAGE_DIR')+'/data/sstest/sstest-rc3.fits',1)

rootdir=getenv('DATA')+'/sstest/blanton'
sz=0.25

for i=0L, n_elements(sstest)-1L do begin
    subdir=image_subdir(sstest[i].ra, sstest[i].dec, $
                        prefix=prefix, rootdir=rootdir)
    splog, i
    splog, prefix
    spawn, 'mkdir -p '+subdir
    cd, subdir
    smosaic_dimage, sstest[i].ra, sstest[i].dec, sz=sz, prefix=prefix, $
      run=run, scales=scales, /nocl, /jpg

    if(gz_file_test(prefix+'-u.fits')) then $
      detect, /cen, glim=30., gsmooth=10., seed=iseed, /nocl, gbig=3., $
      gsaddle=100., /nogalex, /nostarim
endfor

end

