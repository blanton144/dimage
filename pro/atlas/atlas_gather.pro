;+
; NAME:
;   atlas_gather
; PURPOSE:
;   gather measurements and images of all atlas galaxies
; CALLING SEQUENCE:
;   detect_atlas_all [, infile=, /sample]
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro atlas_gather, sample=sample, subname=subname
  
  rootdir='/global/data/atlas/v0'
  if(NOT keyword_set(infile)) then $
     infile=getenv('DIMAGE_DIR')+'/data/atlas/atlas.fits'
  if(NOT keyword_set(outfile)) then $
     outfile=getenv('DIMAGE_DIR')+'/data/atlas/atlas_measure.fits'
  if(keyword_set(sample)) then begin
     infile= getenv('DIMAGE_DIR')+'/data/atlas/atlas_sample.fits'
     outfile= getenv('DIMAGE_DIR')+'/data/atlas/atlas_sample_measure.fits'
     rootdir= '/global/data/atlas/sample'
  endif
  
  atlas= gz_mrdfits(infile, 1)
  
  for i=0L, n_elements(atlas)-1L do begin
      if((i mod 100) eq 0) then $
        splog, i
      
      atcd, i, subname=subname
     
      tmp_measure=0
      dreadcen, measure=tmp_measure
      
      if(n_tags(tmp_measure) gt 0) then begin
          if(n_tags(measure) eq 0) then begin
              measure0= tmp_measure[0]
              struct_assign, {junk:0}, measure0
              measure= replicate(measure0, n_elements(atlas))
              measure.aid=-1L
          endif
          measure[i]= tmp_measure
      endif
      
  endfor

  mwrfits, measure, outfile, /create
     
end
