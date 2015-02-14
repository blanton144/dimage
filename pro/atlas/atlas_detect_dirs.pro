;+
; NAME:
;   atlas_detect_dirs
; PURPOSE:
;   create atlas detection directories
; CALLING SEQUENCE:
;   atlas_detect_dirs [, /sdss ]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_detect_dirs, sdss=sdss, justjpg=justjpg, galex=galex, $
                       st=st, nd=nd, version=version, noclobber=noclobber, $
                       subname=in_subname
                       

  if(keyword_set(sdss)) then begin
     galex=0
     twomass=0
     sdss=1
     jpg=1
     subname='detect-sdss'
  endif  else if(keyword_set(galex)) then begin
     galex=1
     twomass=0
     sdss=1
     jpg=1
     subname='detect-galex'
  endif else if(keyword_set(justjpg)) then begin
     galex=0
     twomass=0
     sdss=0
     jpg=1
     subname='detect-sdss'
  endif else begin
     galex=1
     twomass=1
     wise=0
     sdss=1
     jpg=1
     subname='detect'
  endelse
  if(keyword_set(in_subname) ne 0) then $
     subname=in_subname

  rootdir=atlas_rootdir(version=version)
  if(NOT keyword_set(infile)) then $
     infile=rootdir+'/catalogs/atlas.fits'

  atlas= gz_mrdfits(infile, 1)

  if(NOT keyword_set(st)) then st=0L
  if(NOT keyword_set(nd)) then nd=n_elements(atlas)-1L
  for i=st, nd do begin
     if((i mod 1000) eq 0) then $
        splog, i
     rootdir=atlas_rootdir(version=version, subname=subname)
     subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir=rootdir, $
                         subname=subname)
     
     file_mkdir, subdir
     cd, subdir

     finfo= file_info('.')
     if(finfo.write eq 0) then begin
        splog, 'Directory not writable, skipping!'
        continue
     endif

     sdsssub= 'sdss'
     sdssdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                          prefix=prefix, rootdir=rootdir+'/'+'detect', $
                          subname=sdsssub)

     if(keyword_set(jpg)) then begin
        jpgfile=prefix+'.jpg'
        if(file_test(sdssdir+'/'+jpgfile)) then begin
           if(keyword_set(noclobber) eq 0 or $
              file_test(subdir+'/'+jpgfile) eq 0) then begin
              file_delete, subdir+'/'+jpgfile, /allow
              file_link, sdssdir+'/'+jpgfile, subdir+'/'+jpgfile
           endif
        endif
     endif
     
     if(keyword_set(sdss)) then begin
        imfiles=prefix+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
        for iband=0L, n_elements(imfiles)-1L do begin
           if(file_test(sdssdir+'/'+imfiles[iband])) then begin
              if(keyword_set(noclobber) eq 0 or $
                 file_test(subdir+'/'+imfiles[iband]) eq 0) then begin
                 file_delete, subdir+'/'+imfiles[iband], /allow
                 file_link, sdssdir+'/'+imfiles[iband], subdir+'/'+imfiles[iband]
              endif
           endif
        endfor
     endif

     if(keyword_set(galex)) then begin
        galexsub= 'galex'
        galexdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                              prefix=prefix, rootdir=rootdir+'/'+'detect', $
                              subname=galexsub)
        imfiles=prefix+'-'+['nd', 'fd']+'.fits.gz'
        for iband=0L, n_elements(imfiles)-1L do begin
           if(keyword_set(noclobber) eq 0 or $
              file_test(subdir+'/'+imfiles[iband]) eq 0) then begin
              if(file_test(galexdir+'/'+imfiles[iband])) then begin
                 file_delete, subdir+'/'+imfiles[iband], /allow
                 file_link, galexdir+'/'+imfiles[iband], '.'
              endif else begin
                 file_delete, subdir+'/'+imfiles[iband], /allow
                 ufile= prefix+'-u.fits'
                 hdr= gz_headfits(ufile)
                 if(size(hdr, /tname) eq 'STRING') then begin
                    nx_sdss=long(sxpar(hdr, 'NAXIS1'))
                    ny_sdss=long(sxpar(hdr, 'NAXIS2'))
                    dra= float(nx_sdss)*0.396/3600.
                    ddec= float(ny_sdss)*0.396/3600.
                    xyad, hdr, (float(nx_sdss)-1.)/2., (float(ny_sdss)-1.)/2., $
                          racen, deccen
                    ast= hogg_make_astr(racen, deccen, dra, ddec, pix=1.5/3600.)
                    nx= ast.naxis[0]
                    ny= ast.naxis[1]
                    gim= fltarr(nx, ny)
                    mkhdr, ghdr, gim
                    putast, ghdr, ast
                    outfile= strmid(imfiles[iband],0,strlen(imfiles[iband])-3)
                    mwrfits, gim, subdir+'/'+outfile, ghdr, /create
                    spawn, /nosh, ['gzip', '-vf', subdir+'/'+outfile]
                 endif
              endelse
           endif 
        endfor
     endif

     if(keyword_set(twomass)) then begin
        twomasssub= '2mass'
        twomassdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                                prefix=prefix, rootdir=rootdir+'/'+'detect', $
                                subname=twomasssub)
        imfiles=prefix+'-'+['J', 'H', 'K']+'.fits.gz'
        for iband=0L, n_elements(imfiles)-1L do begin
           if(keyword_set(noclobber) eq 0 or $
              file_test(subdir+'/'+imfiles[iband]) eq 0) then begin
              if(file_test(twomassdir+'/'+imfiles[iband])) then begin
                 file_delete, subdir+'/'+imfiles[iband], /allow
                 file_link, twomassdir+'/'+imfiles[iband], '.'
              endif else begin
                 file_delete, subdir+'/'+imfiles[iband], /allow
                 ufile= prefix+'-u.fits'
                 hdr= gz_headfits(ufile)
                 if(size(hdr, /tname) eq 'STRING') then begin
                    nx_sdss=long(sxpar(hdr, 'NAXIS1'))
                    ny_sdss=long(sxpar(hdr, 'NAXIS2'))
                    dra= float(nx_sdss)*0.396/3600.
                    ddec= float(ny_sdss)*0.396/3600.
                    xyad, hdr, (float(nx_sdss)-1.)/2., (float(ny_sdss)-1.)/2., $
                          racen, deccen
                    ast= hogg_make_astr(racen, deccen, dra, ddec, pix=1./3600.)
                    nx= ast.naxis[0]
                    ny= ast.naxis[1]
                    tim= fltarr(nx, ny)
                    mkhdr, thdr, tim
                    putast, thdr, ast
                    outfile= strmid(imfiles[iband],0,strlen(imfiles[iband])-3)
                    mwrfits, tim, subdir+'/'+outfile, thdr, /create
                    spawn, /nosh, ['gzip', '-vf', subdir+'/'+outfile]
                 endif
              endelse
           endif
        endfor
     endif
     
     if(keyword_set(wise)) then begin
        wisesub= 'wise'
        wisedir=image_subdir(atlas[i].ra, atlas[i].dec, $
                             prefix=prefix, rootdir=rootdir+'/'+'detect', $
                             subname=wisesub)
        imfiles=prefix+'-'+['J', 'H', 'K']+'.fits.gz'
        for iband=0L, n_elements(imfiles)-1L do begin
           if(keyword_set(noclobber) eq 0 or $
              file_test(subdir+'/'+imfiles[iband]) eq 0) then begin
              if(file_test(wisedir+'/'+imfiles[iband])) then begin
                 file_delete, subdir+'/'+imfiles[iband], /allow
                 file_link, wisedir+'/'+imfiles[iband], '.'
              endif else begin
                 file_delete, subdir+'/'+imfiles[iband], /allow
                 ufile= prefix+'-u.fits'
                 hdr= gz_headfits(ufile)
                 if(size(hdr, /tname) eq 'STRING') then begin
                    nx_sdss=long(sxpar(hdr, 'NAXIS1'))
                    ny_sdss=long(sxpar(hdr, 'NAXIS2'))
                    dra= float(nx_sdss)*0.396/3600.
                    ddec= float(ny_sdss)*0.396/3600.
                    xyad, hdr, (float(nx_sdss)-1.)/2., (float(ny_sdss)-1.)/2., $
                          racen, deccen
                    ast= hogg_make_astr(racen, deccen, dra, ddec, pix=1./3600.)
                    nx= ast.naxis[0]
                    ny= ast.naxis[1]
                    tim= fltarr(nx, ny)
                    mkhdr, thdr, tim
                    putast, thdr, ast
                    outfile= strmid(imfiles[iband],0,strlen(imfiles[iband])-3)
                    mwrfits, tim, subdir+'/'+outfile, thdr, /create
                    spawn, /nosh, ['gzip', '-vf', subdir+'/'+outfile]
                 endif
              endelse
           endif
        endfor
     endif
     
  endfor
  
end
