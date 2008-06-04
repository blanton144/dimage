pro blanton_sstest

sstest=mrdfits(getenv('DIMAGE_DIR')+'/data/sstest/sstest-rc3.fits',1)

rootdir=getenv('DATA')+'/sstest/blanton'
sz=0.25

;;for i=0L, n_elements(sstest)-1L do begin
for i=5L, 5L do begin
    subdir=image_subdir(sstest[i].ra, sstest[i].dec, $
                        prefix=prefix, rootdir=rootdir)
    splog, i
    splog, prefix
    spawn, 'mkdir -p '+subdir
    cd, subdir
    smosaic_dimage, sstest[i].ra, sstest[i].dec, sz=sz, prefix=prefix, $
      run=run, scales=scales, /nocl, /jpg

    if(gz_file_test(prefix+'-u.fits')) then $
      detect, /cen, glim=20., gsmooth=5., seed=iseed, /nocl, /gbig, $
      /nogalex
endfor

end

