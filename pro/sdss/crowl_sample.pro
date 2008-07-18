;+
; NAME:
;   crowl_sample
; PURPOSE:
;   make images for crowl sample
; CALLING SEQUENCE:
;   crowl_sample 
; REVISION HISTORY:
;   3-Aug-2004  MRB, NYU
;-
;------------------------------------------------------------------------------
pro crowl_sample

sz=0.2
iseed= 100
run=[1458, $
     1462, $
     2168, $
     2190, $
     2247, $
     3031, $
     3063, $
     3064, $
     3229, $
     3525, $
     3631, $
     3804, $
     3805, $
     3836, $
     3841, $
     3842, $
     3903, $
     3970, $
     4381, $
     5225, $
     5314, $
     5360, $
     5376, $
     5382, $
     5390]
scales=[4.,5.,6.]

readcol, getenv('DIMAGE_DIR')+'/data/crowl.dat', name, ra, dec, $
  f='(a,d,d)'

for i=0L, n_elements(name)-1L do begin
    if(name[i] eq 'ngc4192' OR $
       name[i] eq 'ngc4254' OR $
       name[i] eq 'ngc4501' OR $
       name[i] eq 'ngc4548') then begin
        splog, i
        prefix=name[i]
        
        spawn, 'mkdir -p '+prefix
        cd, prefix
        smosaic_dimage, ra[i], dec[i], sz=sz, prefix=prefix, /raw, $
          run=run, scales=scales, /nocl, /jpg, minscore=0.
        gmosaic_make, ra[i], dec[i], sz, prefix=prefix, /sky, /nocl
        
        detect, /cen, glim=20., gsmooth=10., seed=iseed, /nocl
        
        sdss_detect_html
        cd, '../'
    endif
    
endfor

end
