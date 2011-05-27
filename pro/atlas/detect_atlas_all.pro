;+
; NAME:
;   detect_atlas_all
; PURPOSE:
;   run detect_atlas on everything
; CALLING SEQUENCE:
;   detect_atlas_all [, infile=, /sample]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro detect_atlas_all, infile=infile, sample=sample, sdss=sdss, st=st, nd=nd, $
                      noclobber=noclobber, galex=galex, notrim=notrim, $
                      nodetect=nodetect

  if(keyword_set(sdss)) then begin
      galex=0
      twomass=0
      subname='detect-sdss'
  endif else if(keyword_set(galex)) then begin
      galex=1
      twomass=0
      subname='detect-galex'
  endif else begin
      galex=1
      twomass=1
      subname='detect'
  endelse

  rootdir=atlas_rootdir(sample=sample)
  if(NOT keyword_set(infile)) then $
     infile=getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits'
  if(keyword_set(sample)) then begin
     infile= getenv('DIMAGE_DIR')+'/data/atlas/atlas_sample.fits'
  endif

  atlas= gz_mrdfits(infile, 1)
  
  if(NOT keyword_set(st)) then st=0L
  if(NOT keyword_set(nd)) then nd=n_elements(atlas)-1L
  nd= nd < (n_elements(atlas)-1)
  for i=st, nd do begin
      
     help, i

     subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir=rootdir, $
                         subname=subname)
     
     cd, subdir

     imfiles=prefix+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
     if (keyword_set(galex) gt 0) then begin
         imfiles=[imfiles, prefix+'-'+['nd', 'fd']+'.fits.gz']
     endif 
     if (keyword_set(twomass) gt 0) then begin
         imfiles=[imfiles, prefix+'-'+['J', 'H', 'K']+'.fits.gz']
     endif 
     allthere=1
     for j=0L, n_elements(imfiles)-1L do $
       if(file_test(imfiles[j]) eq 0) then $
       allthere=0
     
     if(allthere gt 0) then begin
         if(NOT keyword_set(nodetect)) then begin
             detect_atlas, galex=galex, twomass=twomass, noclobber=noclobber
             atlas_jpeg, noclobber=noclobber
         endif
         dmeasure_atlas, noclobber=noclobber
         spawn, /nosh, ['find', '.', '-name', '*.fits', '-exec', 'gzip', '-vf', '{}', ';']

         if(NOT keyword_set(notrim)) then $
           dtrim_atlas
     endif
 endfor
 
end
