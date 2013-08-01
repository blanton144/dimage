;+
; NAME:
;   atlas_wise
; PURPOSE:
;   make the atlas WISE images
; CALLING SEQUENCE:
;   atlas_wise_images 
; COMMENTS:
;   Rewritten to use command line WISE tools
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_wise_images, st=st, nd=nd, sample=sample, clobber=clobber, $
                        version=version

  rootdir= atlas_rootdir(version=version)
  atlas=gz_mrdfits(rootdir+'/catalogs/atlas.fits', 1)
  
  bands=['3.4', '4.6', '12', '22']
  mexecbands=['3.4', '4.6', '12', '22']
  vega2ab=[2.699, 3.339, 5.174, 6.620]
  
  if(NOT keyword_set(st)) then st=0L
  if(NOT keyword_set(nd)) then nd=n_elements(atlas)-1L
  for i=st, nd do begin
      help, i
     subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir=rootdir, $
                         subname='detect/wise')
     
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
           dirname= prefix+'-'+bands[iband]+'-work'
           filename= prefix+'-'+bands[iband]+'.fits'
           hdrname= prefix+'-'+bands[iband]+'.hdr'

           ;; get hdr 
           cmd= ['mHdr', $
                 '-t', mexecbands[iband], $
                 '"'+rastr+' '+decstr+'"', $
                 sizestr, $
                 hdrname]
           spawn, /nosh, cmd
        
           ;; get image 
           cmd= ['mExec', $
                 '-l', $
                 '-o', filename, $
                 '-d', '2', $
                 '-f', hdrname, $
                 'wise', dirname]
           spawn, /nosh, cmd
           
           spawn, 'gzip -vf '+filename
        endfor
        
        montage_recal, prefix, bands=bands, vega2ab=vega2ab
     endif
        
     runjpg=0
     filename=prefix+'-W123.jpg'
     if(file_test(filename) eq 0 OR keyword_set(clobber) ne 0) then $
        runjpg=1
     if(runjpg) then begin
        scales=[4., 5., 6.]*0.002
        satvalue=2500.
        nonlinearity=3.
        
        try=1
        spawn, /nosh, ['fitsverify', '-q', prefix[0]+'-3.4.fits.gz'], outstr
        words= strsplit(outstr, /extr)
        if(words[1] eq 'FAILED:') then $
           try=0
        spawn, /nosh, ['fitsverify', '-q', prefix[0]+'-4.6.fits.gz'], outstr
        words= strsplit(outstr, /extr)
        if(words[1] eq 'FAILED:') then $
           try=0
        spawn, /nosh, ['fitsverify', '-q', prefix[0]+'-12.fits.gz'], outstr
        words= strsplit(outstr, /extr)
        if(words[1] eq 'FAILED:') then $
           try=0
        if(try) then $
           djs_rgb_make, prefix[0]+'-3.4.fits.gz', $
                         prefix[0]+'-4.6.fits.gz', $
                         prefix[0]+'-12.fits.gz', $
                         name=filename, $
                         scales=scales, $
                         nonlinearity=nonlinearity, satvalue=satvalue, $
                         quality=100.
     endif
  endfor
  
end
