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
pro detect_atlas_all, infile=infile, sample=sample
  
  rootdir='/global/data/atlas/v0'
  if(NOT keyword_set(infile)) then $
     infile=getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits'
  if(keyword_set(sample)) then begin
     infile= getenv('DIMAGE_DIR')+'/data/atlas/atlas_sample.fits'
     rootdir= '/global/data/atlas/sample'
  endif

  atlas= gz_mrdfits(infile, 1)
  
  ;; 353 bad
  for i=354, n_elements(atlas)-1L do begin
     subdir=image_subdir(atlas[i].ra, atlas[i].dec, $
                         prefix=prefix, rootdir=rootdir)
     
     cd, subdir

     imfiles=prefix+'-'+['u', 'g', 'r', 'i', 'z']+'.fits.gz'
     if (keyword_set(galex) gt 0) then begin
        imfiles=prefix+'-'+['u', 'g', 'r', 'i', 'z', 'nd', 'fd']+'.fits.gz'
     endif 
     allthere=1
     for j=0L, n_elements(imfiles)-1L do $
        if(file_test(imfiles[j]) eq 0) then $
           allthere=0

     if(allthere gt 0) then begin
        detect_atlas
        atlas_jpeg
     endif
  endfor
     
end