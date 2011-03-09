;+
; NAME:
;   stamps_measure
; PURPOSE:
;   Measure fake stamps for petro quantities for comparison to West
;-
pro stamps_measure

stamps= mrdfits(getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_info_003.fits',1)

for i=0L, n_elements(stamps)-1L do begin
   help,i 
   im= mrdfits(stamps[i].stamp)
   xcen= float((size(im,/dim))[0]/2L)
   ycen= float((size(im,/dim))[1]/2L)
   dmeasure, im, xcen=xcen, ycen=ycen, /fixcen, measure=tmp_measure
   if(n_tags(measure) eq 0) then $
      measure= replicate(tmp_measure, n_elements(stamps))
   measure[i]=tmp_measure
endfor

mwrfits, measure, getenv('DIMAGE_DIR')+'/data/fake/fake_stamps_measure_003.fits', $
         /create
end
