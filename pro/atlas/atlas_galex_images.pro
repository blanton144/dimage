;+
; NAME:
;   atlas_galex
; PURPOSE:
;   make the atlas GALEX images
; CALLING SEQUENCE:
;   atlas_galex_images 
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_galex_images, st=st, nd=nd, sample=sample, clobber=clobber

  if(NOT keyword_set(sample)) then begin
     atlas=gz_mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits', 1)
     rootdir='/mount/hercules5/sdss/atlas/v0'
  endif else begin
     atlas=gz_mrdfits(getenv('DIMAGE_DIR')+'/data/atlas/atlas_sample.fits', 1)
     rootdir='/mount/hercules5/sdss/atlas/sample'
  endelse
  
  bands=['nd', 'fd']
  
  if(NOT keyword_set(st)) then st=0L
  if(NOT keyword_set(nd)) then nd=n_elements(atlas)-1L
  for i=st, nd do begin
     subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir=rootdir, $
                         subname='galex')
     
     spawn, /nosh, ['mkdir', '-p' ,subdir]
     cd, subdir

     rungmosaic= keyword_set(clobber) ne 0
     for iband=0L, n_elements(bands)-1L do begin
        filename= prefix[0]+'-'+bands[iband]+'.fits'
        if(gz_file_test(filename) eq 0) then $
           rungmosaic=rungmosaic OR 1
     endfor

     if(rungmosaic) then begin
        gmosaic_make, atlas[i].ra, atlas[i].dec, atlas[i].size, prefix=prefix, $
                      /avoidinterp
     endif
     
     runjpg=0
     filename=prefix+'-fnn.jpg'
     if(file_test(filename) eq 0 OR keyword_set(clobber) ne 0) then $
        runjpg=1
     if(runjpg) then begin
        scales=[4., 5., 6.]*0.2
        satvalue=2500.
        nonlinearity=3.
        djs_rgb_make, prefix[0]+'-nd.fits.gz', $
                      prefix[0]+'-nd.fits.gz', $
                      prefix[0]+'-fd.fits.gz', $
                      name=filename, $
                      scales=scales, $
                      nonlinearity=nonlinearity, satvalue=satvalue, $
                      quality=100.
     endif
  endfor
  
end
