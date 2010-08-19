;+
; NAME:
;   detect_fakes
; PURPOSE:
;   Run detect on fakes
; CALLING SEQUENCE:
;   detect_fakes, name
; COMMENTS:
;   Takes smosaics from indir and reorganizes into directory under:
;      /global/data/scr/mb144/skyfake/[name]
; REVISION HISTORY:
;   2-Aug-2010 MRB, NYU
;-
pro detect_fakes, name

dirs= file_search('/global/data/scr/mb144/skyfake/'+name+'/*')

for i=0L, n_elements(dirs)-1L do begin
    cd, dirs[i]
    detect, /cen, glim=10., gsmooth=4., plim=10.,/nogalex, $
      pbuffer=0.5, /nostarim, maxnstar=15L
    dmeasure_multi, dirs[i]
endfor

end
