;+
; NAME:
;   atlas_2mass
; PURPOSE:
;   make the atlas 2MASS images
; CALLING SEQUENCE:
;   atlas_2mass_images 
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_2mass_images, st=st, nd=nd, sample=sample, clobber=clobber, $
                        version=version

  rootdir= atlas_rootdir(sample=sample, version=version)
  if(NOT keyword_set(sample)) then begin
     atlas=gz_mrdfits(rootdir+'/catalogs/atlas.fits', 1)
  endif else begin
     atlas=gz_mrdfits(rootdir+'/catalogs/atlas_sample.fits', 1)
  endelse
  
  bands=['J', 'H', 'K']
  
  if(NOT keyword_set(st)) then st=0L
  if(NOT keyword_set(nd)) then nd=n_elements(atlas)-1L
  for i=st, nd do begin
      help, i
     subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir=rootdir, $
                         subname='2mass')
     
     spawn, /nosh, ['mkdir', '-p' ,subdir]
     cd, subdir

     runmontage= keyword_set(clobber) ne 0
     for iband=0L, n_elements(bands)-1L do begin
        filename= prefix[0]+'-'+bands[iband]+'.fits'
        if(gz_file_test(filename) eq 0) then $
           runmontage=runmontage OR 1
     endfor

     if(runmontage) then begin
        rastr= strtrim(string(f='(f40.20)', atlas[i].ra),2)
        decstr= strtrim(string(f='(f40.20)', atlas[i].dec),2)
        sizestr= strtrim(string(f='(f40.5)', atlas[i].size),2)
        
        for iband=0L, n_elements(bands)-1L do begin
           filename= prefix+'-'+bands[iband]+'.fits'
           spawn, 'getMontage '+filename+' '+bands[iband]+' '+ $
                  rastr+' '+decstr+' '+sizestr
           spawn, 'gzip -vf '+filename
        endfor
        
        montage_recal, prefix, bands=bands
     endif
        
     runjpg=0
     filename=prefix+'-JHK.jpg'
     if(file_test(filename) eq 0 OR keyword_set(clobber) ne 0) then $
        runjpg=1
     if(runjpg) then begin
        scales=[4., 5., 6.]*0.002
        satvalue=2500.
        nonlinearity=3.
        
        try=1
        spawn, /nosh, ['fitsverify', '-q', prefix[0]+'-J.fits.gz'], outstr
        words= strsplit(outstr, /extr)
        if(words[1] eq 'FAILED:') then $
           try=0
        spawn, /nosh, ['fitsverify', '-q', prefix[0]+'-H.fits.gz'], outstr
        words= strsplit(outstr, /extr)
        if(words[1] eq 'FAILED:') then $
           try=0
        spawn, /nosh, ['fitsverify', '-q', prefix[0]+'-K.fits.gz'], outstr
        words= strsplit(outstr, /extr)
        if(words[1] eq 'FAILED:') then $
           try=0
        if(try) then $
           djs_rgb_make, prefix[0]+'-K.fits.gz', $
                         prefix[0]+'-H.fits.gz', $
                         prefix[0]+'-J.fits.gz', $
                         name=filename, $
                         scales=scales, $
                         nonlinearity=nonlinearity, satvalue=satvalue, $
                         quality=100.
     endif
  endfor
  
end
